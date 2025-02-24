// calendar_plugin_platform_interface.dart
import 'package:music/app/component/notifiers/play_button_notifier.dart';
import 'package:music/app/component/notifiers/progress_notifier.dart';
import 'package:music/app/models/song.dart';
import 'package:music/platform/plugin_method_channel.dart.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/services.dart';

abstract class PluginPlatform extends PlatformInterface {
     PluginPlatform() : super(token: _token);

  static final Object _token = Object();
  static PluginPlatform _instance = MethodChannelPlugin();

  static PluginPlatform get instance => _instance;

  static set instance(PluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // 方法通道方法
  Future<void> play(Song url) async {}
  Future<void> pause() async {}
  Future<void> resume() async {}
  Future<void> seek(int position) async {}

  // 事件流
  Stream<int> get positionStream => const Stream.empty();
  Stream<int> get durationStream => const Stream.empty();
  Stream<void> get completeStream => const Stream.empty();
  Stream<String> get errorStream => const Stream.empty();
  Stream<void> get seekCompleteStream => const Stream.empty();
  Stream<ProgressBarState>  get processStream => const Stream.empty();
     Stream<ButtonState>  get buttonStream => const Stream.empty();
}