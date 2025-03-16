//
//  back.swift
//  Runner
//
//  Created by knight on 2025/3/4.
//
//
//import Foundation
//
////  MusicPlayerManager.swift
////  tesmusic
////
////  Created by knight on 2025/2/19.
////
//import Foundation
//import MediaPlayer
//import AVFoundation
//import MobileCoreServices
//import CommonCrypto
//class MusicPlayerManager2: NSObject {
//    private var channel: FlutterMethodChannel
//    private var player: AVPlayer?
//    private var timeObserverToken: Any?
//    
//    init(binaryMessenger: FlutterBinaryMessenger) {
//        channel = FlutterMethodChannel(name: "soramusic.com/sora_player", binaryMessenger: binaryMessenger)
//        super.init()
//        channel.setMethodCallHandler(handleMethodCall)
//        
//        self.player = AVPlayer()
//        self.setupRemoteTransportControls()
//        self.setupAudioSession()
//    }
//    
//    deinit {
//        cleanupObservers()
//    }
//    
//    enum PlayerState: String {
//        case stopped = "stopped"
//        case playing = "playing"
//        case paused = "paused"
//        case completed = "completed"
//        case loading = "loading"
//    }
//    
//    private var currentState: PlayerState = .stopped {
//        didSet {
//            onStateChange(currentState)
//            channel.invokeMethod("onPlayerStateChanged", arguments: currentState.rawValue)
//        }
//    }
//    
//    var onStateChange: (PlayerState) -> Void = { _ in }
//    
//    // MARK: - Flutter 方法处理
//    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        switch call.method {
//        case "play":
//            guard let args = call.arguments as? [String: Any],
//                      let url = args["url"] as? String,
//                      let title = args["title"] as? String,
//                      let artist = args["artist"] as? String,
//                      let album = args["album"] as? String,
//                      let artwork = args["artwork"] as? String else {
//                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
//        
//                
//                    return
//                }
//                self.loadTrack(url: url, artwork: artwork, artist: artist, title: title, album: album)
//    
//
//            
//        case "pause":
//            self.pause()
//        case "seek":
//            guard let args = call.arguments as? [String: Any],
//                  let positionMilliseconds = args["position"] as? Double else {
//                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for seek", details: nil))
//                return
//            }
//            let positionSeconds = positionMilliseconds / 1000
//            self.player?.seek(to: CMTime(seconds: positionSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))) { [weak self] finished in
//                if finished {
//                    self?.updateNowPlaying(isPlaying: self?.player?.rate != 0)
//                    self?.channel.invokeMethod("onSeekCompleted", arguments: positionSeconds)
//                }
//            }
//        case "fetchLocalSongs":
//            
//            fetchLocalSongs { songs in
//                // 在这里使用歌曲数据
//                self.channel.invokeMethod("fetchLocalSongs", arguments: songs)
//            }
//        default:
//            result(FlutterMethodNotImplemented)
//        }
//    }
//    
//    
//
// 
//    
//    // MARK: - 音频会话配置
//    private func setupAudioSession() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback)
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("音频会话设置失败: \(error)")
//        }
//    }
//    
//    // MARK: - 远程控制设置
//    private func setupRemoteTransportControls() {
//        let commandCenter = MPRemoteCommandCenter.shared()
//        
//        commandCenter.playCommand.addTarget { [weak self] _ in
//            self?.play()
//            return .success
//        }
//        
//        commandCenter.pauseCommand.addTarget { [weak self] _ in
//            self?.pause()
//            return .success
//        }
//        
//        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
//            self?.previousTrack()
//            return .success
//        }
//        
//        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
//            self?.nextTrack()
//            return .success
//        }
//        
//        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
//            guard let self = self,
//                  let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
//            
//            let targetTime = CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//            self.player?.seek(to: targetTime) { [weak self] finished in
//                if finished {
//                    self?.updateNowPlaying(isPlaying: self?.player?.rate != 0)
//                    self?.channel.invokeMethod("onSeek", arguments: Int(targetTime.seconds))
//                }
//            }
//            return .success
//        }
//        
//        commandCenter.playCommand.isEnabled = true
//        commandCenter.pauseCommand.isEnabled = true
//        commandCenter.previousTrackCommand.isEnabled = true
//        commandCenter.nextTrackCommand.isEnabled = true
//    }
//    
//    // MARK: - 更新锁屏信息
//    private func updateNowPlaying(isPlaying: Bool) {
//        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
//        
//        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
//        
//        if let player = self.player {
//            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
//            
//            if let duration = player.currentItem?.asset.duration {
//                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(duration)
//            }
//        }
//        
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//    }
//    
//    // MARK: - 播放控制
//    func play() {
//        player?.play()
//        updateNowPlaying(isPlaying: true)
//    }
//    
//    func pause() {
//        player?.pause()
//        updateNowPlaying(isPlaying: false)
//    }
//    
//    private func previousTrack() {
//        // 实现上一曲逻辑
//    }
//    
//    private func nextTrack() {
//        // 实现下一曲逻辑
//    }
//    
//    // MARK: - 加载曲目
//    public func loadTrack(url: String, artwork: String, artist: String, title: String, album: String) {
//        guard let sourceURL = URL(string: url) else {
//            return
//        }
//        
//        // 2. 判断媒体库文件
//             if isMediaLibraryURL(sourceURL) {
//                 print("🔍 检测到媒体库文件")
//                 handleMediaLibraryItem(url: sourceURL,
//                                      artwork: artwork,
//                                      artist: artist,
//                                      title: title,
//                                      album: album)
//                 return
//             }else{
//                
//                        guard ["http", "https"].contains(sourceURL.scheme?.lowercased()) else {
//                            print("❌ 不支持的协议类型: \(sourceURL.scheme ?? "nil")")
//                            return
//                        }
//                        
//                        // 4. 获取本地存储路径
//                        let localFileURL = getLocalFilePath(for: sourceURL)
//                        print("📁 本地缓存路径: \(localFileURL.path)")
//                        
//                        // 5. 清理旧播放器
//                        cleanupObservers()
//                        
//                        // 6. 文件存在性判断
//                        if localFileExists(for: sourceURL) {
//                            print("✅ 使用本地缓存文件")
//                            setupPlayer(with: localFileURL)
//                   
//                            play()
//                            return
//                        }else{
//                            // 7. 初始化网络播放
//                            print("🌐 开始网络播放")
//                            setupPlayer(with: sourceURL)
//                            
//                            play()
//                            
//                            // 8. 后台下载存储
//                            startBackgroundDownload(from: sourceURL, to: localFileURL)                                 }
//                        
//                      
//             }
//        
//         
//        
//    }
//    
//    
//    
//    private func handleMediaLibraryItem(url: URL, artwork: String, artist: String, title: String, album: String) {
//        print("🎵 处理媒体库文件")
//        
//        // 1. 创建媒体库播放项
//        let playerItem = AVPlayerItem(url: url)
//        
//         
//        
//        // 3. 初始化播放器
//        player = AVPlayer(playerItem: playerItem)
//        setupObservers(for: playerItem)
//        
//        // 4. 开始播放
//        play()
//    }
//    
//    // MARK: - 播放器初始化
//       private func setupPlayer(with url: URL) {
//           print("🎧 初始化播放器")
//           let playerItem = AVPlayerItem(url: url)
//           player = AVPlayer(playerItem: playerItem)
//           setupObservers(for: playerItem)
//       }
//       
//       // MARK: - 后台下载逻辑
//       private func startBackgroundDownload(from sourceURL: URL, to localURL: URL) {
//           print("⏬ 开始后台下载")
//           
//           let downloadTask = URLSession.shared.downloadTask(with: sourceURL) { [weak self] tempURL, _, error in
//               guard let self = self else { return }
//               
//               if let error = error {
//                   print("❌ 下载失败: \(error.localizedDescription)")
//                   return
//               }
//               
//               guard let tempURL = tempURL else {
//                   print("❌ 无效的临时文件路径")
//                   return
//               }
//               
//               do {
//                   // 移动文件到永久目录
//                   try FileManager.default.moveItem(at: tempURL, to: localURL)
//                   print("✅ 文件已保存至: \(localURL.path)")
//                   
//                   // 更新播放器到本地文件
//                   DispatchQueue.main.async {
//                       self.updatePlayerToLocalFile(localURL)
//                   }
//               } catch {
//                   print("❌ 文件移动失败: \(error.localizedDescription)")
//               }
//           }
//           downloadTask.resume()
//       }
//       
//       // MARK: - 更新本地播放源
//       private func updatePlayerToLocalFile(_ localURL: URL) {
//           print("🔄 切换到本地文件")
//           
//           // 保留当前播放时间
//           let currentTime = player?.currentTime()
//           
//           // 创建新的播放项
//           let newPlayerItem = AVPlayerItem(url: localURL)
//           player?.replaceCurrentItem(with: newPlayerItem)
//           
//           // 恢复播放进度
//           if let currentTime = currentTime {
//               player?.seek(to: currentTime)
//           }
//           
//           // 重新设置观察者
//           if let currentItem = player?.currentItem {
//               setupObservers(for: currentItem)
//           }
//       }
//       
//       // MARK: - 文件管理方法
//       private func getLocalFilePath(for url: URL) -> URL {
//           let fileName = generateFileName(from: url)
//           return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//               .appendingPathComponent(fileName)
//       }
//       
//       private func localFileExists(for url: URL) -> Bool {
//           let filePath = getLocalFilePath(for: url)
//           return FileManager.default.fileExists(atPath: filePath.path)
//       }
//       
//       private func generateFileName(from url: URL) -> String {
//           let urlString = url.absoluteString
//           let data = Data(urlString.utf8)
//           var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
//           
//           data.withUnsafeBytes {
//               CC_MD5($0.baseAddress, CC_LONG(data.count), &digest)
//           }
//           
//           let md5Hex = digest.map { String(format: "%02hhx", $0) }.joined()
//           return "\(md5Hex).\(url.pathExtension)"
//       }    // MARK: - 媒体库文件处理
//       private func isMediaLibraryURL(_ url: URL) -> Bool {
//           return url.scheme?.lowercased() == "ipod-library"
//       }
//       
//     
//       
//    // MARK: - 媒体库元数据加载
//    private func loadMediaLibraryMetadata(for item: AVPlayerItem,
//                                        artwork: String,
//                                        artist: String,
//                                        title: String,
//                                        album: String) {
//        print("📚 加载媒体库元数据")
//        
//        item.asset.loadValuesAsynchronously(forKeys: ["commonMetadata"]) { [weak self] in
//            guard let self = self else { return }
//            
//            // 主线程更新UI
//            DispatchQueue.main.async {
//                // 1. 初始化最终数据
//                var finalTitle = title
//                var finalArtist = artist
//                var finalAlbum = album
//                var embeddedArtwork: UIImage?
//                
//                // 2. 遍历元数据项
//                let metadata = item.asset.commonMetadata
//                for metaItem in metadata {
//                    switch metaItem.commonKey {
//                    case .commonKeyTitle where finalTitle.isEmpty:
//                        finalTitle = metaItem.stringValue ?? title
//                    case .commonKeyArtist where finalArtist.isEmpty:
//                        finalArtist = metaItem.stringValue ?? artist
//                    case .commonKeyAlbumName where finalAlbum.isEmpty:
//                        finalAlbum = metaItem.stringValue ?? album
//                    case .commonKeyArtwork:
//                        if let data = metaItem.dataValue {
//                            embeddedArtwork = UIImage(data: data)
//                        }
//                    default:
//                        break
//                    }
//                }
//                
//            
//                
//                // 4. 加载封面图（优先使用内嵌封面）
//                self.loadCombinedArtwork(embeddedImage: embeddedArtwork,
//                                         fallbackPath: artwork, completion: <#(UIImage?) -> Void#>)
//            }
//        }
//    }
//  
//    // MARK: - 组合封面加载
//    private func loadCombinedArtwork(embeddedImage: UIImage?,
//                                   fallbackPath: String,
//                                   completion: @escaping (UIImage?) -> Void) {
//        // 1. 优先使用内嵌封面
//        if let embedded = embeddedImage {
//            print("🖼 使用内嵌封面")
//            completion(embedded)
//            return
//        }
//        
//        // 2. 备用封面加载逻辑
//        if fallbackPath.lowercased().hasPrefix("http") {
//            print("🌐 加载网络封面")
//            loadArtworkFromURL(fallbackPath, completion: completion)
//        } else if !fallbackPath.isEmpty {
//            print("🔐 解析Base64封面")
//            loadArtworkFromBase64(fallbackPath, completion: completion)
//        } else {
//            print("⚠️ 无可用封面资源")
//            completion(nil)
//        }
//    }
//    
//    
//    private func loadArtworkFromURL(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
//        // 清理 URL 字符串（去除空格和非法字符）
//        let cleanedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//        
//        // 检查 URL 是否有效
//        guard let artworkUrl = URL(string: cleanedUrlString), !cleanedUrlString.isEmpty else {
//            print("无效的 URL: \(urlString)")
//            completion(nil)
//            return
//        }
//        
//        // 使用 URLSession 加载图片数据
//        URLSession.shared.dataTask(with: artworkUrl) { data, response, error in
//            // 检查数据是否有效，以及是否有错误
//            if let error = error {
//                print("加载图片失败: \(error.localizedDescription)")
//                completion(nil)
//                return
//            }
//            
//            guard let data = data, let image = UIImage(data: data) else {
//                print("无法将数据转换为图片或没有数据")
//                completion(nil)
//                return
//            }
//            
//            // 成功加载后，通过完成处理器返回图片
//            DispatchQueue.main.async {
//                completion(image)
//            }
//        }.resume()
//    }
//    
//    private func loadArtworkFromBase64(_ base64String: String,completion: @escaping (UIImage?) -> Void) -> UIImage? {
//        guard let imageData = Data(base64Encoded: base64String) else {
//                print("无效的Base64数据")
//                completion(nil)
//                
//            }
//            
//            DispatchQueue.main.async {
//                completion(UIImage(data: imageData))
//            }
//    }
//    
//    private func updateNowPlayingInfo(with image: UIImage? = nil, artist: String, title: String, album: String) {
//        var nowPlayingInfo = [String: Any]()
//        
//        nowPlayingInfo[MPMediaItemPropertyTitle] = title
//        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
//        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
//        
//        if let image = image {
//            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in return image }
//            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
//        }
//        
//        if let duration = player?.currentItem?.asset.duration {
//            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(duration)
//        }
//        
//        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
//        
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//    }
//    
//    @objc private func playerDidFinishPlaying(note: NSNotification) {
//        currentState = .completed
//    }
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        let playerItem = player?.currentItem
//        if keyPath == "rate" {
//            if let rate = player?.rate, rate > 0 {
//                currentState = .playing
//            } else if currentState != .paused {
//                currentState = .paused
//            }
//        } else if keyPath == "status" {
//            if playerItem?.status == .readyToPlay {
//                currentState = .loading
//            } else if playerItem?.status == .failed {
//                currentState = .stopped
//            }
//        }
//    }
//    
//    // MARK: - Observers
//    private func setupObservers(for item: AVPlayerItem) {
//        timeObserverToken = player?.addPeriodicTimeObserver(
//            forInterval: CMTime(seconds: 1, preferredTimescale: 1000),
//            queue: .main
//        ) { [weak self] time in
//            guard let self = self else { return }
//            let currentTime = time.seconds
//            
//            if let item = self.player?.currentItem {
//                let total = CMTimeGetSeconds(item.duration)
//                let buffered = self.calculateBufferedSeconds(for: item)
//                
//                self.channel.invokeMethod("onBufferingUpdate", arguments: [
//                    "current": currentTime,
//                    "buffered": buffered,
//                    "total": total
//                ])
//            }
//        }
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
//        player?.addObserver(self, forKeyPath: "rate", options: [.new, .initial], context: nil)
//        player?.currentItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
//    }
//    
//    private func cleanupObservers() {
//        if let token = timeObserverToken {
//            player?.removeTimeObserver(token)
//            timeObserverToken = nil
//        }
//        NotificationCenter.default.removeObserver(self)
//        player?.currentItem?.removeObserver(self, forKeyPath: "status")
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
//    }
//    
//    // MARK: - Helper Methods
//    private func calculateBufferedSeconds(for item: AVPlayerItem) -> Double {
//        guard let timeRange = item.loadedTimeRanges.first?.timeRangeValue else { return 0 }
//        return CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
//    }
//    
//    
//    
//    
//    func fetchLocalSongs(completion: @escaping ([[String: Any]]) -> Void) {
//        var songs: [[String: Any]] = []
//        
//        // 请求媒体库权限
//        MPMediaLibrary.requestAuthorization { status in
//            if status == .authorized {
//                // 创建查询对象
//                let query = MPMediaQuery.songs()
//                
//                // 设置过滤条件（可选）：排除 iCloud 中的歌曲
//                let filter = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem, comparisonType: .equalTo)
//                query.addFilterPredicate(filter)
//                
//                // 获取本地歌曲
//                if let items = query.items {
//                    for item in items {
//                        var songInfo: [String: Any] = [:]
//                        
//                        // 提取歌曲元数据
//                        songInfo["url"] = item.assetURL?.absoluteString ?? ""
//                        songInfo["title"] = item.title ?? "未知标题"
//                        songInfo["artist"] = item.artist ?? "未知艺术家"
//                        songInfo["albumTitle"] = item.albumTitle ?? "未知专辑"
//                        songInfo["genre"] = item.genre ?? "未知流派"
//                        songInfo["playbackDuration"] = item.playbackDuration
//                        songInfo["albumTrackNumber"] = item.albumTrackNumber
//                        songInfo["albumTrackCount"] = item.albumTrackCount
//                        songInfo["discNumber"] = item.discNumber
//                        songInfo["discCount"] = item.discCount
//                        songInfo["isExplicitItem"] = item.isExplicitItem
//                        songInfo["releaseDate"] = item.releaseDate
//                        songInfo["playCount"] = item.playCount
//                        songInfo["skipCount"] = item.skipCount
//                        songInfo["rating"] = item.rating
//                        songInfo["lastPlayedDate"] = item.lastPlayedDate
//                        
//                        // 专辑封面
//                        if let artwork = item.artwork {
//                            songInfo["albumArtwork"] = artwork.image(at: CGSize(width: 300, height: 300))?.pngData()?.base64EncodedString() ?? ""
//                        } else {
//                            songInfo["albumArtwork"] = ""
//                        }
//                        
//                        // 音频质量信息
//                        songInfo["sampleRate"] = item.value(forProperty: "sampleRate") as? Double ?? 0.0
//                        songInfo["bitRate"] = item.value(forProperty: "bitRate") as? Double ?? 0.0
//                        
//                        songs.append(songInfo)
//                    }
//                }
//                // 返回歌曲数据
//                completion(songs)
//            } else {
//                print("未授权访问媒体库")
//                completion([]) // 返回空数组
//            }
//        }
//    }
//    
//    
//      
//       
//}
//
