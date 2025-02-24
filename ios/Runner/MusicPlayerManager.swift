//
//  MusicPlayerManager.swift
//  tesmusic
//
//  Created by knight on 2025/2/19.
//
import Foundation
import MediaPlayer
import AVFoundation

class MusicPlayerManager: NSObject {
    private var channel: FlutterMethodChannel
    private var player: AVPlayer?
    
    private var _timeObserverToken: Any?
    private var _statusObservation: NSKeyValueObservation?
    private var _interruptionObserver: NSObjectProtocol?
    private var _bufferObserver: NSKeyValueObservation?
    
    private var play_status: String = "stopped" {
        didSet {
            playStatusDidChange(to: play_status)
        }
    }
    
    init(binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "soramusic.com/sora_player", binaryMessenger: binaryMessenger)
        super.init()
        channel.setMethodCallHandler(handleMethodCall)
        
                
        self.player = AVPlayer()
        self.setupRemoteTransportControls()
        self.setupAudioSession()
    }
    
    deinit {
        cleanupObservers()
    }
    
    func playStatusDidChange(to newStatus: String) {
       switch newStatus {
        case "play":
            channel.invokeMethod("play_state", arguments: String("play"))
        case "pause":
           channel.invokeMethod("play_state", arguments: String("pause"))
        case "prev":
           channel.invokeMethod("play_state", arguments: String("prev"))
        case "next":
           channel.invokeMethod("play_state", arguments: String("next"))
        default:
           return
        }
    }
    
    // MARK: - Flutter 方法处理
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "play":
            guard let args = call.arguments as? [String: Any],
                  let url = args["url"] as? String,
                  let title = args["title"] as? String,
                  let artist = args["artist"] as? String,
                  let album = args["album"] as? String,
                  let artwork = args["artwork"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }
            self.loadTrack(url: url, artwork: artwork, artist: artist, title: title, album: album)
        case "pause":
            self.pause()
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - 音频会话配置
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话设置失败: \(error)")
        }
    }
    
    // MARK: - 远程控制设置
    public func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // 播放按钮回调
        commandCenter.playCommand.addTarget { [weak self] _ in
            print("Play button pressed") // 打印日志
            self?.play()
            return .success
        }
        
        // 暂停按钮回调
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            print("Pause button pressed") // 打印日志
            self?.pause()
            return .success
        }
        
        // 上一曲按钮回调
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            print("Previous track button pressed") // 打印日志
            self?.previousTrack()
            return .success
        }
        
        // 下一曲按钮回调
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            print("Next track button pressed") // 打印日志
            self?.nextTrack()
            return .success
        }
        
        // 确保命令可用
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        
        
        // 添加改变播放位置命令
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let self = self,
                  let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            
            let targetTime = CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            self.player?.seek(to: targetTime) { [weak self] finished in
                if finished {
                    self?.updateNowPlaying(isPlaying: self?.player?.rate != 0)
                    self?.channel.invokeMethod("onSeek", arguments: Int(targetTime.seconds))
                    
                }
            }
            return .success
        }
        
    }
    
    
    // MARK: - 更新锁屏信息
    private func updateNowPlaying(isPlaying: Bool) {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        
        // 更新播放状态
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // 更新播放进度
        if let player = self.player {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            
            // 总时长应已在此字典中，如果没有，则可以重新添加
            if let duration = player.currentItem?.asset.duration {
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(duration)
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - 播放控制
    func play() {
        player?.play()
        updateNowPlaying(isPlaying: true)
        play_status = "play"
    }
    
    func pause() {
        player?.pause()
        updateNowPlaying(isPlaying: false)
        play_status = "pause"
    }
    
    private func previousTrack() {
        play_status = "prev"
        print("play_status",play_status)
    }
    
    private func nextTrack() {
        play_status = "next"
        print("play_status",play_status)
    }
    
    // MARK: - 加载曲目
    public func loadTrack(url: String, artwork: String, artist: String, title: String, album: String) {
        guard let url = URL(string: url) else {
            return
        }
        
        // 清理旧的观察者
        cleanupObservers()
        
        // 创建新的 AVPlayerItem
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // 设置新的观察者
        setupObservers(for: playerItem)
        
        // 播放
        play()
        
        // 加载封面图片
        guard let artworkUrl = URL(string: artwork) else { return }
        URLSession.shared.dataTask(with: artworkUrl) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else { return }
            let image = UIImage(data: data)
            self.updateNowPlayingInfo(with: image, artist: artist, title: title, album: album)
        }.resume()
    }
    
    // MARK: - 更新锁屏信息
    private func updateNowPlayingInfo(with image: UIImage? = nil, artist: String, title: String, album: String) {
        var nowPlayingInfo = [String: Any]()
        
        // 基础信息
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        
        // 封面图片
        if let image = image {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                return image
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        // 播放时长
        if let duration = player?.currentItem?.asset.duration {
            let seconds = CMTimeGetSeconds(duration)
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = seconds
        }
        
        // 播放进度
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    
    // MARK: - Observers
    private func setupObservers(for item: AVPlayerItem) {
        // 时间观察者
        _timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 1000),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            let currentTime = time.seconds
            self.channel.invokeMethod("onPosition", arguments: Int(currentTime))
        }

        // 状态观察者
        _statusObservation = item.observe(\.status, options: [.new, .initial]) { [weak self] (item, _) in
            guard let self = self else { return }
            switch item.status {
            case .readyToPlay:
                let duration = item.asset.duration.seconds
                self.channel.invokeMethod("onDuration", arguments: Int(duration))
            case .failed:
                let errorMessage = "Playback failed: \(item.error?.localizedDescription ?? "")"
                self.channel.invokeMethod("onError", arguments: errorMessage)
            default: break
            }
        }
        
        // 缓冲观察者
        _bufferObserver = item.observe(\.loadedTimeRanges) { [weak self] (item, _) in
            guard let self = self else { return }
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
    
    private func cleanupObservers() {
        if let token = _timeObserverToken {
            player?.removeTimeObserver(token)
            _timeObserverToken = nil
        }
        _statusObservation = nil
        _bufferObserver = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    // MARK: - Helper Methods
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
}
