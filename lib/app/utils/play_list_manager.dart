import 'dart:math';

import 'dart:math';

import 'package:music/app/models/play_model.dart';

class PlaylistManager {
  List<String> _playlist = [];
  int _currentIndex = 0;
  PlayMode _playMode = PlayMode.sequence; // 默认顺序播放
  List<int> _shuffleIndices = []; // 随机播放索引列表

  // 单例模式
  static final PlaylistManager _instance = PlaylistManager._internal();
  factory PlaylistManager() => _instance;
  PlaylistManager._internal();

  // 设置播放列表
  void setPlaylist(List<String> urls) {
    _playlist = urls;
    _currentIndex = 0;
    _generateShuffleIndices();
  }

  // 生成随机播放索引
  void _generateShuffleIndices() {
    _shuffleIndices = List.generate(_playlist.length, (i) => i);
    _shuffleIndices.shuffle();
  }

  // 下一首
  String next() {
    if (_playlist.isEmpty) return '';

    switch (_playMode) {
      case PlayMode.sequence:
        _currentIndex = (_currentIndex + 1) % _playlist.length;
        break;
      case PlayMode.loop:
        _currentIndex = (_currentIndex + 1) % _playlist.length;
        break;
      case PlayMode.shuffle:
        _currentIndex = (_currentIndex + 1) % _playlist.length;
        return _playlist[_shuffleIndices[_currentIndex]];
    }

    return _playlist[_currentIndex];
  }

  // 上一首
  String previous() {
    if (_playlist.isEmpty) return '';

    switch (_playMode) {
      case PlayMode.sequence:
        _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
        break;
      case PlayMode.loop:
        _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
        break;
      case PlayMode.shuffle:
        _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
        return _playlist[_shuffleIndices[_currentIndex]];
    }

    return _playlist[_currentIndex];
  }

  // 切换播放模式
  void togglePlayMode() {
    switch (_playMode) {
      case PlayMode.sequence:
        _playMode = PlayMode.loop;
        break;
      case PlayMode.loop:
        _playMode = PlayMode.shuffle;
        _generateShuffleIndices();
        break;
      case PlayMode.shuffle:
        _playMode = PlayMode.sequence;
        break;
    }
  }

  // 获取当前歌曲
  String get currentSong => _playlist.isNotEmpty
      ? (_playMode == PlayMode.shuffle
      ? _playlist[_shuffleIndices[_currentIndex]]
      : _playlist[_currentIndex])
      : '';

  // 获取当前播放模式
  PlayMode get playMode => _playMode;
}