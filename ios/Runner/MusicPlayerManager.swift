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
    private var timeObserverToken: Any?
    
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
    
    enum PlayerState: String {
        case stopped = "stopped"
        case playing = "playing"
        case paused = "paused"
        case completed = "completed"
        case loading = "loading"
    }
    
    private var currentState: PlayerState = .stopped {
        didSet {
            onStateChange(currentState)
            channel.invokeMethod("onPlayerStateChanged", arguments: currentState.rawValue)
        }
    }
    
    var onStateChange: (PlayerState) -> Void = { _ in }
    
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
        case "seek":
            guard let args = call.arguments as? [String: Any],
                  let positionMilliseconds = args["position"] as? Double else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for seek", details: nil))
                return
            }
            let positionSeconds = positionMilliseconds / 1000
            self.player?.seek(to: CMTime(seconds: positionSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))) { [weak self] finished in
                if finished {
                    self?.updateNowPlaying(isPlaying: self?.player?.rate != 0)
                    self?.channel.invokeMethod("onSeekCompleted", arguments: positionSeconds)
                }
            }
        case "fetchLocalSongs":
            
            fetchLocalSongs { songs in
                // 在这里使用歌曲数据
                self.channel.invokeMethod("fetchLocalSongs", arguments: songs)
            }
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
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousTrack()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.nextTrack()
            return .success
        }
        
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
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
    }
    
    // MARK: - 更新锁屏信息
    private func updateNowPlaying(isPlaying: Bool) {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        if let player = self.player {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            
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
    }
    
    func pause() {
        player?.pause()
        updateNowPlaying(isPlaying: false)
    }
    
    private func previousTrack() {
        // 实现上一曲逻辑
    }
    
    private func nextTrack() {
        // 实现下一曲逻辑
    }
    
    // MARK: - 加载曲目
    public func loadTrack(url: String, artwork: String, artist: String, title: String, album: String) {
        guard let url = URL(string: url) else {
            return
        }
        
        cleanupObservers()
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        setupObservers(for: playerItem)
        play()
        
        loadArtwork(from: artwork, artist: artist, title: title, album: album)
    }
    
    private func loadArtwork(from urlString: String, artist: String, title: String, album: String) {
        // 检查是否是 HTTP/HTTPS URL
        if urlString.lowercased().hasPrefix("http://") || urlString.lowercased().hasPrefix("https://") {
            // 处理普通 URL
            loadArtworkFromURL(urlString, artist: artist, title: title, album: album)
        } else {
            // 假设是 Base64 图像数据
            loadArtworkFromBase64(urlString, artist: artist, title: title, album: album)
        }
    }

    private func loadArtworkFromURL(_ urlString: String, artist: String, title: String, album: String) {
        // 清理 URL 字符串（去除空格和非法字符）
        let cleanedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // 检查 URL 是否有效
        guard let artworkUrl = URL(string: cleanedUrlString), !cleanedUrlString.isEmpty else {
            print("无效的 URL: \(urlString)")
            return
        }

        // 使用 URLSession 加载图片数据
        URLSession.shared.dataTask(with: artworkUrl) { [weak self] data, response, error in
            // 检查 self 是否存在，数据是否有效，以及是否有错误
            guard let self = self, let data = data, error == nil else {
                print("加载图片失败: \(error?.localizedDescription ?? "未知错误")")
                return
            }

            // 将数据转换为 UIImage
            if let image = UIImage(data: data) {
                // 更新正在播放的信息
                self.updateNowPlayingInfo(with: image, artist: artist, title: title, album: album)
            } else {
                print("无法将数据转换为图片")
            }
        }.resume()
    }

    private func loadArtworkFromBase64(_ base64String: String, artist: String, title: String, album: String) {
        // 将 Base64 字符串解码为 Data
        if let imageData = Data(base64Encoded: base64String) {
            // 将 Data 转换为 UIImage
            if let image = UIImage(data: imageData) {
                // 更新正在播放的信息
                self.updateNowPlayingInfo(with: image, artist: artist, title: title, album: album)
            } else {
                print("Base64 数据无法转换为图片")
            }
        } else {
            print("Base64 数据无效")
        }
    }
    
    private func updateNowPlayingInfo(with image: UIImage? = nil, artist: String, title: String, album: String) {
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        
        if let image = image {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in return image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        if let duration = player?.currentItem?.asset.duration {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(duration)
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        currentState = .completed
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let playerItem = player?.currentItem
        if keyPath == "rate" {
            if let rate = player?.rate, rate > 0 {
                currentState = .playing
            } else if currentState != .paused {
                currentState = .paused
            }
        } else if keyPath == "status" {
            if playerItem?.status == .readyToPlay {
                currentState = .loading
            } else if playerItem?.status == .failed {
                currentState = .stopped
            }
        }
    }
    
    // MARK: - Observers
    private func setupObservers(for item: AVPlayerItem) {
        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 1000),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            let currentTime = time.seconds
            
            if let item = self.player?.currentItem {
                let total = CMTimeGetSeconds(item.duration)
                let buffered = self.calculateBufferedSeconds(for: item)
                
                self.channel.invokeMethod("onBufferingUpdate", arguments: [
                    "current": currentTime,
                    "buffered": buffered,
                    "total": total
                ])
            }
        }

       NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.addObserver(self, forKeyPath: "rate", options: [.new, .initial], context: nil)
       player?.currentItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
    }
    
    private func cleanupObservers() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        NotificationCenter.default.removeObserver(self)
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    // MARK: - Helper Methods
    private func calculateBufferedSeconds(for item: AVPlayerItem) -> Double {
        guard let timeRange = item.loadedTimeRanges.first?.timeRangeValue else { return 0 }
        return CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
    }
    
    
    
    
    func fetchLocalSongs(completion: @escaping ([[String: Any]]) -> Void) {
        var songs: [[String: Any]] = []
        
        // 请求媒体库权限
        MPMediaLibrary.requestAuthorization { status in
            if status == .authorized {
                // 创建查询对象
                let query = MPMediaQuery.songs()
                
                // 设置过滤条件（可选）：排除 iCloud 中的歌曲
                let filter = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem, comparisonType: .equalTo)
                query.addFilterPredicate(filter)
                
                // 获取本地歌曲
                if let items = query.items {
                    for item in items {
                        var songInfo: [String: Any] = [:]
                        
                        // 提取歌曲元数据
                        songInfo["url"] = item.assetURL?.absoluteString ?? ""
                        songInfo["title"] = item.title ?? "未知标题"
                        songInfo["artist"] = item.artist ?? "未知艺术家"
                        songInfo["albumTitle"] = item.albumTitle ?? "未知专辑"
                        songInfo["genre"] = item.genre ?? "未知流派"
                        songInfo["playbackDuration"] = item.playbackDuration
                        songInfo["albumTrackNumber"] = item.albumTrackNumber
                        songInfo["albumTrackCount"] = item.albumTrackCount
                        songInfo["discNumber"] = item.discNumber
                        songInfo["discCount"] = item.discCount
                        songInfo["isExplicitItem"] = item.isExplicitItem
                        songInfo["releaseDate"] = item.releaseDate
                        songInfo["playCount"] = item.playCount
                        songInfo["skipCount"] = item.skipCount
                        songInfo["rating"] = item.rating
                        songInfo["lastPlayedDate"] = item.lastPlayedDate
                        
                        // 专辑封面
                        if let artwork = item.artwork {
                            songInfo["albumArtwork"] = artwork.image(at: CGSize(width: 300, height: 300))?.pngData()?.base64EncodedString() ?? ""
                        } else {
                            songInfo["albumArtwork"] = ""
                        }
                        
                        // 音频质量信息
                        songInfo["sampleRate"] = item.value(forProperty: "sampleRate") as? Double ?? 0.0
                        songInfo["bitRate"] = item.value(forProperty: "bitRate") as? Double ?? 0.0
                        
                        songs.append(songInfo)
                    }
                }
                // 返回歌曲数据
                completion(songs)
            } else {
                print("未授权访问媒体库")
                completion([]) // 返回空数组
            }
        }
    }
    
    
}
