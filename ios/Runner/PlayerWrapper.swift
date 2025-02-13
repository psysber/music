//
//  PlayerWrapper.swift
//  Runner
//
//  Created by knight on 2025/2/10.
//
 
import Foundation
import Flutter
import AVKit
import MediaPlayer
class PlayerWrapper: NSObject {
    private var channel: FlutterMethodChannel
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var statusObservation: NSKeyValueObservation?
    private var endObserver: NSObjectProtocol?
    private var interruptionObserver: NSObjectProtocol?
    private var timeRangesObservation: NSKeyValueObservation?
    private var bufferObserver: NSObjectProtocol?
    
    
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
    
    private func play(url: String, result: FlutterResult) {
           guard let url = URL(string: url) else {
               result(FlutterError(code: "INVALID_URL", message: "URL 格式错误", details: nil))
               return
           }
           player?.pause()

           cleanupObservers() // 清理旧的播放器资源

           let playerItem = AVPlayerItem(url: url)
           player = AVPlayer(playerItem: playerItem)
           player?.play()

           setupObservers(for: playerItem)
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
            print("Sending position to Flutter: \(Int(time.seconds))")
            self?.channel.invokeMethod("onPosition", arguments: Int(time.seconds))
        }

        // 播放状态观察
        statusObservation = item.observe(\.status) { [weak self] (item, _) in
            switch item.status {
            case .readyToPlay:
                let duration = item.asset.duration.seconds
                print("Sending duration to Flutter: \(Int(duration))")
                self?.channel.invokeMethod("onDuration", arguments: Int(duration))
            case .failed:
                let errorMessage = "播放失败: \(item.error?.localizedDescription ?? "")"
                print("Sending error to Flutter: \(errorMessage)")
                self?.channel.invokeMethod("onError", arguments: errorMessage)
            default: break
            }
        }

        // 播放完成通知
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: nil
        ) { [weak self] _ in
            print("Sending completion event to Flutter")
            self?.channel.invokeMethod("onComplete", arguments: nil)
        }
        
        timeRangesObservation = item.observe(\.loadedTimeRanges, options: [.new]) { [weak self] (item, _) in
                  self?.sendBufferingPercentage(item: item)
              }
        // 缓冲进度观察
               bufferObserver = item.observe(\.loadedTimeRanges) { [weak self] (item, _) in
                   guard let self = self else { return }
                   let bufferedPercentage = self.calculateBufferedPercentage(for: item)
                   self.channel.invokeMethod("onBuffered", arguments: bufferedPercentage)
               }
    }
    
    
    
    private func calculateBufferedPercentage(for item: AVPlayerItem) -> Int {
          guard let firstRange = item.loadedTimeRanges.first?.timeRangeValue else { return 0 }
          let bufferedSeconds = CMTimeGetSeconds(firstRange.start) + CMTimeGetSeconds(firstRange.duration)
          let totalDuration = CMTimeGetSeconds(item.duration)
          guard totalDuration > 0 else { return 0 }
          return Int((bufferedSeconds / totalDuration) * 100)
      }
    
    
    private func sendBufferingPercentage(item: AVPlayerItem) {
        let durationSeconds = item.duration.seconds
        if durationSeconds.isNaN || durationSeconds <= 0 {
            return
        }
        
        guard let timeRange = item.loadedTimeRanges.first?.timeRangeValue else {
            return
        }
        
        let bufferedTime = timeRange.start.seconds + timeRange.duration.seconds
        let progress = bufferedTime / durationSeconds
        let percentage = Int(progress * 100)
        
        DispatchQueue.main.async {
            self.channel.invokeMethod("onBufferingUpdate", arguments: percentage)
        }
    }

    
    private func cleanupObservers() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        statusObservation?.invalidate()
        if let observer = endObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        timeRangesObservation?.invalidate()
              timeRangesObservation = nil
        
    }
    
    // 查询本地歌曲
    func queryLocalSongs(result: @escaping FlutterResult) {
           let authorizationStatus = MPMediaLibrary.authorizationStatus()
           if authorizationStatus == .authorized {
               fetchSongs(result: result)
           } else {
               MPMediaLibrary.requestAuthorization { status in
                   if status == .authorized {
                       self.fetchSongs(result: result)
                   } else {
                       DispatchQueue.main.async {
                           result(FlutterError(code: "PERMISSION_DENIED", message: "访问媒体库被拒绝", details: nil))
                       }
                   }
               }
           }
       }

       private func fetchSongs(result: @escaping FlutterResult) {
           DispatchQueue.global(qos: .userInitiated).async {
               let query = MPMediaQuery.songs()
               guard let items = query.items else {
                   DispatchQueue.main.async {
                       result([])
                   }
                   return
               }

               var songs: [[String: Any]] = []

               for item in items {
                   var song: [String: Any] = [
                       "title": item.title ?? "",
                       "artist": item.artist ?? "",
                       "albumTitle": item.albumTitle ?? "",
                       "genre": item.genre ?? "",
                       "playbackDuration": item.playbackDuration,
                       "albumTrackNumber": item.albumTrackNumber,
                       "albumTrackCount": item.albumTrackCount,
                       "discNumber": item.discNumber,
                       "discCount": item.discCount,
                       "isExplicitItem": item.isExplicitItem,
                       "releaseDate": item.releaseDate?.timeIntervalSince1970 ?? NSNull(),
                       "playCount": item.playCount,
                       "skipCount": item.skipCount,
                       "rating": item.rating,
                       "lastPlayedDate": item.lastPlayedDate?.timeIntervalSince1970 ?? NSNull(),
                       "albumArtwork": NSNull(),
                       "sampleRate": NSNull(),
                       "bitRate": NSNull(),
                       "assetURL": item.assetURL?.absoluteString ?? ""
                   ]

                   // 专辑封面
                   if let artwork = item.artwork, let image = artwork.image(at: CGSize(width: 100, height: 100)) {
                       if let imageData = image.jpegData(compressionQuality: 0.8) {
                           let base64String = imageData.base64EncodedString()
                           song["albumArtwork"] = base64String
                       }
                   }

                   // 获取采样率和比特率
                   if let assetURL = item.assetURL {
                       let asset = AVURLAsset(url: assetURL)
                       if let formatDescription = asset.tracks(withMediaType: .audio).first?.formatDescriptions.first {
                           let desc = formatDescription as! CMAudioFormatDescription
                           if let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(desc)?.pointee {
                               song["sampleRate"] = asbd.mSampleRate
                           }
                       }
                       // 比特率
                       if let bitRate = asset.tracks(withMediaType: .audio).first?.estimatedDataRate {
                           song["bitRate"] = bitRate
                       }
                   }

                   songs.append(song)
               }

               DispatchQueue.main.async {
                   result(songs)
               }
           }
       }
}
 
