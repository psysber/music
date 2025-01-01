import Flutter
import UIKit
import MediaPlayer

public class SoraplayerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "soraplayer", binaryMessenger: registrar.messenger())
    let instance = SoraplayerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "queryLocalMusic":
      result(MeidiaPlayer().queryLocalMusic())
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
