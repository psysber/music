// calendar_plugin_method_channel.dart
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:music/app/component/notifiers/play_button_notifier.dart';
import 'package:music/app/component/notifiers/progress_notifier.dart';
import 'package:music/app/models/song.dart';
import 'package:music/platform/plugin.dart';

class MethodChannelPlugin extends PluginPlatform {
  static const String _channelName = 'soramusic.com/sora_player';
  static const String _methodPlay = 'play';
  static const String _methodPause = 'pause';
  static const String _methodResume = 'resume';
  static const String _methodSeek = 'seek';

  static const String _eventPosition = 'onPosition';
  static const String _eventDuration = 'onDuration';
  static const String _eventComplete = 'onComplete';
  static const String _eventError = 'onError';
  static const String _eventSeekComplete = 'onSeekComplete';
  static const String _eventBufferingUpdate = 'onBufferingUpdate';
  static const String _eventPlayState = 'play_state';

  final MethodChannel _methodChannel = const MethodChannel(_channelName);

  final StreamController<int> _positionController = StreamController.broadcast();
  final StreamController<int> _durationController = StreamController.broadcast();
  final StreamController<void> _completeController = StreamController.broadcast();
  final StreamController<String> _errorController = StreamController.broadcast();
  final StreamController<void> _seekCompleteController = StreamController.broadcast();
  final StreamController<ProgressBarState> _processStream = StreamController.broadcast();
  final StreamController<ButtonState> _buttonStream = StreamController.broadcast();

  MethodChannelPlugin() {
    _methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case _eventPosition:
        _positionController.add(call.arguments as int);
        break;
      case _eventDuration:
        _durationController.add(call.arguments as int);
        break;
      case _eventComplete:
        _completeController.add(null);
        break;
      case _eventError:
        _errorController.add(call.arguments as String);
        break;
      case _eventSeekComplete:
        _seekCompleteController.add(null);
        break;
      case _eventBufferingUpdate:
        _handleBufferingUpdate(call.arguments as Map<String, dynamic>);
        break;
      case _eventPlayState:
        _handlePlayState(call.arguments as Map<String, dynamic>);
        break;
      default:
        throw MissingPluginException();
    }
    return null;
  }

  void _handleBufferingUpdate(Map<String, dynamic> args) {
    var progressBarState = ProgressBarState(
      current: args['current'],
      buffered: args['buffered'],
      total: args['total'],
    );
    _processStream.add(progressBarState);
  }

  void _handlePlayState(Map<String, dynamic> args) {
    final state = args.keys.firstWhere((key) => args[key] == true, orElse: () => '');
    switch (state) {
      case 'play':
        _buttonStream.add(ButtonState.playing);
        break;
      case 'pause':
        _buttonStream.add(ButtonState.paused);
        break;
      case 'complete':
        _buttonStream.add(ButtonState.completed);
        break;
      case 'loading':
        _buttonStream.add(ButtonState.loading);
        break;
      case 'stop':
        _buttonStream.add(ButtonState.stopped);
        break;
      default:
        print('Unknown play state: $state');
        break;
    }
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
  Stream<ProgressBarState> get processStream => _processStream.stream;

  @override
  Stream<ButtonState> get buttonStream => _buttonStream.stream;

  @override
  Future<void> play(Song song) async {
    await _invokeMethod(_methodPlay, {
      'url': song.url,
      'title': song.title,
      'artist': song.artist,
      'album': song.albumTitle,
      'artwork': song.albumArtwork,
    });
  }

  @override
  Future<void> pause() async {
    await _invokeMethod(_methodPause);
  }

  @override
  Future<void> resume() async {
    await _invokeMethod(_methodResume);
  }

  @override
  Future<void> seek(int position) async {
    await _invokeMethod(_methodSeek, {'position': position});
  }

  Future<void> _invokeMethod(String method, [dynamic arguments]) async {
    try {
      await _methodChannel.invokeMethod(method, arguments);
    } on PlatformException catch (e) {
      throw Exception("$method failed: ${e.message}");
    }
  }
}