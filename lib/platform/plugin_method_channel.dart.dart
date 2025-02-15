// calendar_plugin_method_channel.dart
import 'dart:async';

import 'package:flutter/services.dart';

import 'package:music/platform/plugin.dart';

class MethodChannelPlugin extends  PluginPlatform {
  final MethodChannel _methodChannel =
  const MethodChannel('soramusic.com/sora_player');

  final StreamController<int> _positionController = StreamController.broadcast();
  final StreamController<int> _durationController = StreamController.broadcast();
  final StreamController<void> _completeController = StreamController.broadcast();
  final StreamController<String> _errorController = StreamController.broadcast();
  final StreamController<void> _seekCompleteController = StreamController.broadcast();

  MethodChannelPlugin() {
    _methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onPosition':
        _positionController.add(call.arguments as int);
        break;
      case 'onDuration':
        _durationController.add(call.arguments as int);
        break;
      case 'onComplete':
        _completeController.add(null);
        break;
      case 'onError':
        _errorController.add(call.arguments as String);
        break;
      case 'onSeekComplete':
        _seekCompleteController.add(null);
        break;
      default:
        throw MissingPluginException();
    }
    return null;
  }

  @override
  Stream<int> get positionStream => _positionController.stream;

  @override
  Stream<int> get durationStream => _durationController.stream;

  @override
  Stream<void> get completeStream => _completeController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Stream<void> get seekCompleteStream => _seekCompleteController.stream;

  @override
  Future<void> play(String url) async {
    try {
      await _methodChannel.invokeMethod('play', {'url': url});
    } on PlatformException catch (e) {
      throw Exception("播放失败: ${e.message}");
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _methodChannel.invokeMethod('pause');
    } on PlatformException catch (e) {
      throw Exception("暂停失败: ${e.message}");
    }
  }

  @override
  Future<void> resume() async {
    try {
      await _methodChannel.invokeMethod('resume');
    } on PlatformException catch (e) {
      throw Exception("恢复失败: ${e.message}");
    }
  }

  @override
  Future<void> seek(int position) async {
    try {
      await _methodChannel.invokeMethod('seek', {'position': position});
    } on PlatformException catch (e) {
      throw Exception("跳转失败: ${e.message}");
    }
  }
}