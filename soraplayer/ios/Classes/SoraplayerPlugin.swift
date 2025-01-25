import Flutter
import UIKit
import MediaPlayer

@UIApplicationMain
@objc public class SoraplayerPlugin: FlutterAppDelegate, FlutterPlugin {
  var audioPlayer: AVPlayer?
     var progressTimer: Timer?
     var eventSink: FlutterEventSink?

     override func application(
         _ application: UIApplication,
         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
         let controller = window?.rootViewController as! FlutterViewController

         // 设置 Method Channel
         let musicChannel = FlutterMethodChannel(
             name: "com.music.flutter_music_player/music",
             binaryMessenger: controller.binaryMessenger
         )

         musicChannel.setMethodCallHandler { [weak self] (call, result) in
             guard let self = self else { return }
             switch call.method {
             case "playMusic":
                 if let urlString = call.arguments as? [String: Any],
                    let url = urlString["url"] as? String,
                    let musicURL = URL(string: url) {
                     self.playMusic(from: musicURL)
                     result(nil)
                 } else {
                     result(FlutterError(code: "INVALID_URL", message: "Invalid URL provided", details: nil))
                 }
             case "pauseMusic":
                 self.pauseMusic()
                 result(nil)
             case "stopMusic":
                 self.stopMusic()
                 result(nil)
             default:
                 result(FlutterMethodNotImplemented)
             }
         }

         // 设置 Event Channel
         let progressChannel = FlutterEventChannel(
             name: "com.example.flutter_music_player/progress",
             binaryMessenger: controller.binaryMessenger
         )
         progressChannel.setStreamHandler(self)

         GeneratedPluginRegistrant.register(with: self)
         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }

     func playMusic(from url: URL) {
         let playerItem = AVPlayerItem(url: url)
         audioPlayer = AVPlayer(playerItem: playerItem)
         audioPlayer?.play()

         // 启动定时器，每秒发送一次播放进度
         progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
             guard let self = self else { return }
             self.sendProgressUpdate()
         }
     }

     func pauseMusic() {
         audioPlayer?.pause()
         progressTimer?.invalidate()
     }

     func stopMusic() {
         audioPlayer?.pause()
         audioPlayer?.replaceCurrentItem(with: nil)
         progressTimer?.invalidate()
     }

     func sendProgressUpdate() {
         guard let player = audioPlayer else { return }
         let currentTime = CMTimeGetSeconds(player.currentTime())
         let totalDuration = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)

         if let eventSink = eventSink {
             eventSink([
                 "current": currentTime,
                 "total": totalDuration
             ])
         }
     }
  }
}

extension AppDelegate: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
