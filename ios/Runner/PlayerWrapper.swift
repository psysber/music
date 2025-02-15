import UIKit
import Flutter
import AVFoundation
import MediaPlayer
import UserNotifications
class PlayerWrapper: NSObject {
    private var channel: FlutterMethodChannel
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var statusObservation: NSKeyValueObservation?
    private var interruptionObserver: NSObjectProtocol?
    private var bufferObserver: NSKeyValueObservation?

    init(binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "soramusic.com/sora_player", binaryMessenger: binaryMessenger)
        super.init()
        channel.setMethodCallHandler(handleMethodCall)
        setupInterruptionObserver()
    }
    
    deinit {
        cleanupObservers()
        if let observer = interruptionObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
 
    // MARK: - 中断监听
    private func setupInterruptionObserver() {
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            guard let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                      return
                  }

            switch type {
            case .began:
                // 中断开始（如来电），暂停播放
                self?.player?.pause()
            case .ended:
                // 中断结束，尝试恢复播放
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        self?.player?.play()
                    }
                }
            default:
                break
            }
        }
    }
    
    // MARK: - Flutter 方法处理
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "play":
            guard let url = (call.arguments as? [String: Any])?["url"] as? String else {
                result(FlutterError(code: "INVALID_ARG", message: "Missing URL", details: nil))
                return
            }
            play(url: url, result: result)
        case "pause":
            player?.pause()
            result(nil)
        case "resume":
            player?.play()
            result(nil)
        case "seek":
            guard let position = (call.arguments as? [String: Any])?["position"] as? Int else {
                result(FlutterError(code: "INVALID_ARG", message: "Missing position", details: nil))
                return
            }
            seek(to: position, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func play(url: String, result: @escaping FlutterResult) {
        guard let url = URL(string: url) else {
            result(FlutterError(code: "INVALID_URL", message: "URL 格式错误", details: nil))
            return
        }
        player?.pause()

        cleanupObservers() // Clean up old player resources

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        // Store the result closure in a local variable
        var completionResult: FlutterResult? = result

        // Observe player item status
        statusObservation = playerItem.observe(\.status) { [weak self] (item, _) in
            guard let self = self else { return }

            switch item.status {
            case .failed:
                let errorMessage = "播放失败: \(item.error?.localizedDescription ?? "")"
                self.channel.invokeMethod("onError", arguments: errorMessage)
                completionResult?(FlutterError(code: "PLAYBACK_ERROR", message: errorMessage, details: nil))
                completionResult = nil // Ensure the result is only called once
            case .readyToPlay:
                self.player?.play()
                self.setupObservers(for: playerItem)
                completionResult?(nil) // Notify Flutter that playback has started
                completionResult = nil // Ensure the result is only called once
            default:
                break
            }
        }
        
     
    }

    private func pause(result: FlutterResult) {
        player?.pause()
        hideNowPlayingInfo()
        result(nil)
    }

    private func resume(result: FlutterResult) {
        player?.play()
        result(nil)
    }

    private func seek(to position: Int, result: @escaping FlutterResult) {
        let time = CMTime(seconds: Double(position), preferredTimescale: 1000)
        player?.seek(to: time) { [weak self] _ in
            self?.channel.invokeMethod("onSeekComplete", arguments: nil)
            result(nil)
        }
    }
    
    // MARK: - 观察者管理
    private func setupObservers(for item: AVPlayerItem) {
        // 播放进度观察
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: nil) { [weak self] time in
            self?.channel.invokeMethod("onPosition", arguments: Int(time.seconds))
        }

        // 播放状态观察
        statusObservation = item.observe(\.status) { [weak self] (item, _) in
            switch item.status {
            case .readyToPlay:
                let duration = item.asset.duration.seconds
                self?.channel.invokeMethod("onDuration", arguments: Int(duration))
            case .failed:
                let errorMessage = "播放失败: \(item.error?.localizedDescription ?? "")"
                self?.channel.invokeMethod("onError", arguments: errorMessage)
            default: break
            }
        }

        // 缓冲进度观察
        bufferObserver = item.observe(\.loadedTimeRanges) { [weak self] (item, _) in
            guard let self = self else { return }
            let bufferedPercentage = self.calculateBufferedPercentage(for: item)
            let current = CMTimeGetSeconds(item.currentTime())
            let total = CMTimeGetSeconds(item.duration)
            let buffered = self.calculateBufferedSeconds(for: item)
            
            self.channel.invokeMethod("onBufferingUpdate", arguments: [
                "current": current,
                "buffered": buffered,
                "total": total
            ])
        }
    }
    
    private func calculateBufferedPercentage(for item: AVPlayerItem) -> Int {
        guard let firstRange = item.loadedTimeRanges.first?.timeRangeValue else { return 0 }
        let bufferedSeconds = CMTimeGetSeconds(CMTimeRangeGetEnd(firstRange))
        let totalDuration = CMTimeGetSeconds(item.duration)
        guard totalDuration > 0 else { return 0 }
        return Int((bufferedSeconds / totalDuration) * 100)
    }
    
    private func calculateBufferedSeconds(for item: AVPlayerItem) -> Double {
        guard let firstRange = item.loadedTimeRanges.first?.timeRangeValue else { return 0 }
        return CMTimeGetSeconds(CMTimeRangeGetEnd(firstRange))
    }
    
    private func cleanupObservers() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }

        // Invalidate KVO observations
        statusObservation = nil
        bufferObserver = nil
    }

    // MARK: - Now Playing Info
    private func showNowPlayingInfo(title: String, artist: String, albumArtworkURL: String?) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist

        if let urlString = albumArtworkURL, let url = URL(string: urlString) {
            // Load artwork asynchronously
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }.resume()
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func hideNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}


