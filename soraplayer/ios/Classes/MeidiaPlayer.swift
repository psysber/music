//
//  MeidiaPlayer.swift
//  soraplayer
//
//  Created by knight on 2024/12/26.
//

import MediaPlayer
import AVFoundation


public class MeidiaPlayer {
    
    public func queryLocalMusic() -> [[String: Any]] {
        let mediaQuery = MPMediaQuery.songs()
        var songs: [[String: Any]] = []

        if let items = mediaQuery.items {
            for item in items {
                var song: [String: Any] = [:]
                song["title"] = item.title
                song["artist"] = item.artist
                song["albumTitle"] = item.albumTitle
                song["genre"] = item.genre
                song["playbackDuration"] = item.playbackDuration
                song["albumTrackNumber"] = item.albumTrackNumber
                song["albumTrackCount"] = item.albumTrackCount
                song["discNumber"] = item.discNumber
                song["discCount"] = item.discCount
                song["isExplicitItem"] = item.isExplicitItem
                song["releaseDate"] = item.releaseDate
                song["playCount"] = item.playCount
                song["skipCount"] = item.skipCount
                song["rating"] = item.rating
                song["lastPlayedDate"] = item.lastPlayedDate

                // 添加专辑封面图像
                if let artwork = item.artwork {
                    let image = artwork.image(at: CGSize(width: 100, height: 100))
                    if let imageData = image?.pngData() {
                        song["albumArtwork"] = imageData.base64EncodedString()
                    }
                }

                // 添加歌曲采样率和比特率信息
                if let assetURL = item.assetURL {
                    let asset = AVURLAsset(url: assetURL)
                    for format in asset.tracks.first?.formatDescriptions ?? [] {
                        let formatDesc = format as! CMAudioFormatDescription
                        let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc)?.pointee
                        song["sampleRate"] = asbd?.mSampleRate
                        song["bitRate"] = asset.tracks.first?.estimatedDataRate
                    }
                }

                songs.append(song)
            }
        }

        return songs
    }

    var audioPlayer: AVPlayer?



    func playMusic(from url: URL) {
        // 创建 AVPlayerItem
        let playerItem = AVPlayerItem(url: url)

        // 初始化 AVPlayer
        audioPlayer = AVPlayer(playerItem: playerItem)

        // 监听播放完成
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: audioPlayer?.currentItem
        )

        // 监听播放进度
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let currentTime = CMTimeGetSeconds(time)
            print("Current time: \(currentTime)")
        }

        // 开始播放
        audioPlayer?.play()
    }

    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Playback finished")
    }

    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        audioPlayer?.pause()
    }

    @IBAction func stopButtonTapped(_ sender: UIButton) {
        audioPlayer?.replaceCurrentItem(with: nil)
    }

    deinit {
        // 移除监听
        NotificationCenter.default.removeObserver(self)
    }
}
