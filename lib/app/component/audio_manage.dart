import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:music/app/component/notifiers/play_button_notifier.dart';
import 'package:music/app/component/notifiers/repeat_button_notifier.dart';
import 'package:music/app/models/song.dart';
import 'package:music/app/modules/home/modules/play_list.dart';
import 'package:music/platform/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notifiers/progress_notifier.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


// 音频管理类
class AudioManage extends GetxController {
  static final AudioManage _instance = AudioManage._internal();
  factory AudioManage() => _instance;
  AudioManage._internal() {
    init();
  }
  final isOpen = false.obs;
  late SharedPreferences _prefs;
  List<Song> _playlist = <Song>[].obs;
  int _currentIndex = 0;
  final Random _random = Random();

  // 通知器
  final progressNotifier = ProgressNotifier();
  final playButtonNotifier = PlayButtonNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final isLastSongNotifier = ValueNotifier<bool>(false);
  var currentSongNotifier = ValueNotifier<Song?>(null);


      @override
  void onInit() async {
    _prefs = await SharedPreferences.getInstance();
    repeatButtonNotifier.value = RepeatState.repeatPlaylist;
    super.onInit();
  }

  void init() {
    Plugin.processStream.listen((state) => progressNotifier.value = state);
    Plugin.buttonStream.listen((state) => playButtonNotifier.value = state);
    Plugin.completeStream.listen((_) => _handlePlaybackComplete());
  }


  List<Song> getPlayList(){
        return _playlist;
  }

  // 播放控制 ==============================================
  Future<void> play([Song? song]) async {

    try {

      if (song != null) {
        // 查找播放列表中第一个匹配的歌曲（根据标题）
        final existingIndex = _playlist.indexWhere((s) => s.title == song.title);

        if (existingIndex != -1) {
          // 如果存在则跳转到存在的曲目
          _currentIndex = existingIndex;
        } else {
          // 如果不存在则追加到播放列表
          _playlist.add(song);
          _currentIndex = _playlist.length - 1;

        }
      }
      if (_currentIndex < 0 || _currentIndex >= _playlist.length) {
        print('无效的播放索引: $_currentIndex');
        return;
      }

      playButtonNotifier.value = ButtonState.loading;
      _updateCurrentSong();
      await Plugin.play(_playlist[_currentIndex]);
      playButtonNotifier.value = ButtonState.playing;



    } catch (e) {
      playButtonNotifier.value = ButtonState.stopped;
      print('播放失败: $e');
    }

  }

  Future<void> playFromIndex(int index) async {
    try {
      // 检查索引有效性
      if (index < 0 || index >= _playlist.length) {
        print('无效的播放索引: $index');
        return;
      }

      // 设置当前索引并验证播放列表
      _currentIndex = index;
      if (_playlist.isEmpty) return;
      _updateSongStatus();
      var song = _playlist[index];
      currentSongNotifier.value=song;
      // 执行播放操作
      playButtonNotifier.value = ButtonState.loading;
      await Plugin.play(_playlist[_currentIndex]);
      playButtonNotifier.value = ButtonState.playing;

    } catch (e) {
      playButtonNotifier.value = ButtonState.stopped;
      print('播放失败: $e');
    }

  }



  Future<void> pause() async {
    try {
      await Plugin.pause();
      playButtonNotifier.value = ButtonState.paused;
    } catch (e) {
      print('暂停失败: $e');
    }
  }

  Future<void> resume() async {
    try {
      await Plugin.resume();
      playButtonNotifier.value = ButtonState.playing;
    } catch (e) {
      print('恢复失败: $e');
    }
  }

  // 播放列表控制 ==========================================
  void next() {
    if (_playlist.isEmpty) return;

    switch (repeatButtonNotifier.value) {
      case RepeatState.off:
        if (_currentIndex < _playlist.length - 1) {
          _currentIndex++;
          play();
        }
        break;
      case RepeatState.repeatSong:
        play();
        break;
      case RepeatState.repeatPlaylist:
        _currentIndex = (_currentIndex + 1) % _playlist.length;
        play();
        break;
      case RepeatState.randomPlaylist:
        _currentIndex = _random.nextInt(_playlist.length);
        play();
        break;
    }
    _updateCurrentSong();
  }

  void previous() {
    if (_playlist.isEmpty) return;

    switch (repeatButtonNotifier.value) {
      case RepeatState.off:
        if (_currentIndex > 0) {
          _currentIndex--;
          play();
        }
        break;
      case RepeatState.repeatSong:
        play();
        break;
      case RepeatState.repeatPlaylist:
        _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
        play();
        break;
      case RepeatState.randomPlaylist:
        _currentIndex = _random.nextInt(_playlist.length);
        play();
        break;
    }
    _updateCurrentSong();
  }

  // 状态控制 ==============================================
  void repeat() {
    repeatButtonNotifier.nextState();
    _prefs.setInt('repeatState', repeatButtonNotifier.value.index);
  }

  bool get hasNext {
    if (_playlist.isEmpty) return false;
    return repeatButtonNotifier.value != RepeatState.off ||
        _currentIndex < _playlist.length - 1;
  }

  bool get hasPrev {
    if (_playlist.isEmpty) return false;
    return repeatButtonNotifier.value != RepeatState.off ||
        _currentIndex > 0;
  }

  // 辅助方法 ==============================================
  void _updateSongStatus() {
    isFirstSongNotifier.value = _currentIndex == 0;
    isLastSongNotifier.value = _currentIndex == _playlist.length - 1;

  }

  void _updateCurrentSong() {
    currentSongNotifier.value =
    _playlist.isNotEmpty ? _playlist[_currentIndex] : null;
    _updateSongStatus();
  }

  void _handlePlaybackComplete() {
    switch (repeatButtonNotifier.value) {
      case RepeatState.off:
        if (_currentIndex == _playlist.length - 1) {
          playButtonNotifier.value = ButtonState.completed;
        } else {
          playButtonNotifier.value = ButtonState.stopped;
        }
        break;
      case RepeatState.repeatSong:
        play();
        break;
      case RepeatState.repeatPlaylist:
        next();
        break;
      case RepeatState.randomPlaylist:
        next();
        break;
    }
  }

  // 其他方法 ==============================================
  void setPlaylist(List<Song> newPlaylist) {
    _playlist = newPlaylist;
    _currentIndex = 0;
    _updateSongStatus();
    _updateCurrentSong();
  }

  void clearPlayList(){
    _playlist = [];
    _currentIndex = 0;
    _updateSongStatus();
    _updateCurrentSong();
    pause();
  }

  Future<Duration> seek(Duration position) async {
    try {
      await Plugin.seek(position.inMilliseconds);
      return position;
    } catch (e) {
      print('跳转失败: $e');
      return Duration.zero;
    }
  }
}
