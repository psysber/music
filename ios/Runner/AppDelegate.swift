import Flutter
import UIKit
 
import UIKit
import Flutter
import ObjectiveC
import AVFoundation
 
@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 全局配置音频会话
        //setupGlobalAudioSession()
        
        // 注册 Flutter 插件和 PlayerWrapper
        let controller = window?.rootViewController as! FlutterViewController
        DispatchQueue.main.async {
            let playerWrapper = MusicPlayerManager(binaryMessenger: controller.binaryMessenger)
            objc_setAssociatedObject(controller, "PlayerWrapper", playerWrapper, .OBJC_ASSOCIATION_RETAIN)
        }
      
       
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

//    // MARK: - 全局音频配置
//    private func setupGlobalAudioSession() {
//        do {
//            let audioSession = AVAudioSession.sharedInstance()
//            // 使用 `.playback` 类别，允许音频在静音模式下播放
//            try audioSession.setCategory(
//                .playback,
//                mode: .default,options: []
//            )
//            try audioSession.setActive(true)
//        } catch {
//            print("全局音频会话配置失败: \(error.localizedDescription)")
//        }
//    }
//
//    // MARK: - 处理音频中断
//    override func applicationWillResignActive(_ application: UIApplication) {
//        // 应用进入后台时保持音频播放
//        let audioSession = AVAudioSession.sharedInstance()
//        try? audioSession.setActive(true)
//    }
//
//    override func applicationDidBecomeActive(_ application: UIApplication) {
//        // 应用回到前台时恢复音频会话
//        let audioSession = AVAudioSession.sharedInstance()
//        try? audioSession.setActive(true)
//    }
}
