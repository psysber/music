// calendar_plugin.dart


import 'package:flutter/material.dart';
import 'package:music/app/component/notifiers/play_button_notifier.dart';
import 'package:music/app/component/notifiers/progress_notifier.dart';
import 'package:music/app/models/song.dart';
import 'package:music/platform/plugin.dart';

class  Plugin {
  static  PluginPlatform get _platform =>  PluginPlatform.instance;

/*  /// 获取播放位置流
  static Stream<int> get positionStream => _platform.positionStream;

  /// 获取总时长流
  static Stream<int> get durationStream => _platform.durationStream;

  /// 获取播放完成通知流
  static Stream<void> get completeStream => _platform.completeStream;

  /// 获取错误信息流
  static Stream<String> get errorStream => _platform.errorStream;*/

  /// 获取跳转完成通知流
  static Stream<void> get seekCompleteStream => _platform.seekCompleteStream;

  static Stream<ProgressBarState> get processStream => _platform.processStream;

  static Stream<ButtonState> get buttonStream => _platform.buttonStream;

  static Future<void> play(Song url) => _platform.play(url);

  /// 暂停播放
  static Future<void> pause() => _platform.pause();

  /// 恢复播放
  static Future<void> resume() => _platform.resume();

  /// 跳转到指定位置（毫秒）
  static Future<void> seek(int position) => _platform.seek(position);
}