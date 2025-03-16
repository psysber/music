// calendar_plugin_method_channel.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music/app/component/audio_manage.dart';
import 'package:music/app/component/notifiers/play_button_notifier.dart';
import 'package:music/app/component/notifiers/progress_notifier.dart';
import 'package:music/app/models/song.dart';
import 'package:music/app/modules/local_music/controllers/local_music_controller.dart';
import 'package:music/platform/plugin.dart';

class MethodChannelPlugin extends PluginPlatform {
  static const String _channelName = 'soramusic.com/sora_player';
  static const String _methodPlay = 'play';
  static const String _methodPause = 'pause';
  static const String _methodResume = 'resume';
  static const String _methodSeek = 'seek';
  static const String _methodPlayerStateChanged = 'onPlayerStateChanged';
  static const String _eventPosition = 'onPosition';
  static const String _eventDuration = 'onDuration';
  static const String _eventComplete = 'onComplete';
  static const String _eventError = 'onError';
  static const String _eventSeekComplete = 'onSeekComplete';
  static const String _eventBufferingUpdate = 'onBufferingUpdate';
  static const String _fetchLocalSongs = 'fetchLocalSongs';
  static const String _writeToFile = 'writeToFile';
  static const String _next ='next';
  static const String _previous = 'previous';
   //static const String _eventPlayState = 'play_state';

  final MethodChannel _methodChannel = const MethodChannel(_channelName);

  final StreamController<int> _positionController =
      StreamController.broadcast();
  final StreamController<int> _durationController =
      StreamController.broadcast();
  final StreamController<int> _completeController =
      StreamController.broadcast();
  final StreamController<String> _errorController =
      StreamController.broadcast();
  final StreamController<int> _seekCompleteController =
      StreamController.broadcast();
  final StreamController<ProgressBarState> _processStream =
      StreamController.broadcast();
  final StreamController<ButtonState> _buttonStream =
      StreamController.broadcast();

  MethodChannelPlugin() {
    _methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
    /*  *//*case _eventPosition:
        _positionController.add(call.arguments as int);
        break;
      case _eventDuration:
        _durationController.add(call.arguments as int);
        break;
      case _eventComplete:
        _completeController.add("complate");
        break;*//*
      case _eventError:
        _errorController.add(call.arguments as String);
        break;*/
   /*   case 'audioMetadata':
        var arguments = call.arguments;
        print(arguments);*/
      case _previous:
        AudioManage().previous();
        break;
      case _next:
        AudioManage().next();
        break;
      case _fetchLocalSongs:
        final arguments = call.arguments;
        if (arguments is List) {
          final List<Map<String, dynamic>> songMaps = [];
          for (var map in arguments) {
            if (map is Map<Object?, Object?>) {
              // 将 Map<Object?, Object?> 转换为 Map<String, dynamic>
              final convertedMap = Map<String, dynamic>.from(map);
              songMaps.add(convertedMap);
            }
          }

          final List<Song> songs = Song.fromJsonList(songMaps);
          final controller = Get.find<LocalMusicController>();
          controller.localSong.value = songs;
          AudioManage().setPlaylist(songs);
        } else {
          print('Unexpected argument type.');
        }
        break;
      case _methodPlayerStateChanged:
        final String stateString = call.arguments as String;
        if(stateString=="completed"){
         _completeController.add(Random().nextInt(99));
        }
        playhandleMethodCall(stateString);
        break;
      case _eventSeekComplete:
        _seekCompleteController.add(call.arguments as int);
        break;

      case _eventBufferingUpdate:
        var args = call.arguments;
        var progressBarState = ProgressBarState(
          current: Duration(seconds: args['current'].toInt()),
          buffered: Duration(seconds: args['buffered'].toInt()),
          total: Duration(seconds: args['total'].toInt()),
        );

        _processStream.add(progressBarState);
        break;
/*        case _eventPlayState:
        _handlePlayState(call.arguments as Map<String, dynamic>);*/
        break;
      default:
        throw MissingPluginException();
    }
    return null;
  }

  ButtonState _convertToPlayerState(String stateString) {
    switch (stateString) {
      case 'stopped':
        return ButtonState.stopped;
      case 'playing':
        return ButtonState.playing;
      case 'paused':
        return ButtonState.paused;
      case 'completed':
        return ButtonState.completed;
      case 'loading':
        return ButtonState.loading;
      default:
        throw ArgumentError('Unknown player state: $stateString');
    }
  }

  void playhandleMethodCall(String state) {
    final ButtonState playerState = _convertToPlayerState(state);

    switch (playerState) {
      case ButtonState.stopped:
        print('Player is stopped');
        _buttonStream.add(ButtonState.stopped); // 可能需要调整为正确的ButtonState
        break;
      case ButtonState.playing:
        print('Player is playing');
        _buttonStream.add(ButtonState.playing); // 当播放时，按钮应显示为暂停
        break;
      case ButtonState.paused:
        print('Player is paused');
        _buttonStream.add(ButtonState.paused); // 当暂停时，按钮应显示为播放
        break;
      case ButtonState.completed:
        print('Player has completed playback');
        _buttonStream.add(ButtonState.stopped); // 播放结束时，按钮应显示为停止
        break;
      case ButtonState.loading:
        //_buttonStream.add(ButtonState.loading);
        break;
      default:
        throw ArgumentError('Unknown player state: $state');
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

  Future<String> writeToFile(Uint8List content, String fileName) async {
    return await _invokeMethod(
        _writeToFile, {'content': content, 'fileName': fileName});
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

  @override
  Future<void> fetchLocalSongs() async {
    await _invokeMethod(_fetchLocalSongs);
  }

  Future<dynamic> _invokeMethod(String method, [dynamic arguments]) async {
    try {
      return await _methodChannel.invokeMethod(method, arguments);
    } on PlatformException catch (e) {
      throw Exception("$method failed: ${e.message}");
    }
  }


  Future<void> previous()async {}
  Future<void> next()async {}
}
