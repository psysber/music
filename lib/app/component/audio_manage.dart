import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:music/app/component/notifiers/play_button_notifier.dart';
import 'package:music/app/models/song.dart';
import 'package:music/platform/plugin_platform_interface.dart';

import 'notifiers/progress_notifier.dart';

class AudioManage {
  // 单例模式
  static final AudioManage _instance = AudioManage._internal();

  AudioManage._internal(){
    init();
  }

  // 工厂构造函数，用来返回唯一实例
  factory AudioManage() {

    return _instance;
  }


 void init(){
    _processStream.listen((onData){
      progressNotifier.value=onData;
    });
   _buttonStream.listen((value){
     playButtonNotifier.value=value;
   });
  }


  // 进度通知器
  final progressNotifier = ProgressNotifier();
  final playButtonNotifier = PlayButtonNotifier();


 /* // 获取播放位置流
  Stream<int> get positionStream => Plugin.positionStream;

  // 获取总时长流
  Stream<int> get durationStream => Plugin.durationStream;

  // 获取播放完成通知流
  Stream<void> get completeStream => Plugin.completeStream;

  // 获取错误信息流
  Stream<String> get errorStream => Plugin.errorStream;*/


  // 获取跳转完成通知流
  Stream<void> get seekCompleteStream => Plugin.seekCompleteStream;

  // 私有流，用于处理进度更新
  Stream<ProgressBarState> get _processStream => Plugin.processStream;

  Stream<ButtonState> get _buttonStream => Plugin.buttonStream;
  // 开始播放
   void play() async {
    try {

      var song = Song(
          title: "エゴイスト",
          artist: "EGOIST",
          albumTitle: "エゴイスト",
          albumArtwork: "https://jrocknews.com/wp-content/uploads/2017/11/egoist-greatest-hits-2011-2017-alter-ego-artwork-regular-edition.jpg",
          url: "https://music.163.com/song/media/outer/url?id=31649312"
      );
      print("play");
      await Plugin.play(song);
    } catch (e) {
      print('播放失败: $e');
    }
  }

  // 暂停播放
  Future<void> pause() async {
    try {
      await Plugin.pause();
    } catch (e) {
      print('暂停失败: $e');
    }
  }

  // 恢复播放
  Future<void> resume() async {
    try {
      await Plugin.resume();
    } catch (e) {
      print('恢复播放失败: $e');
    }
  }

  // 跳转到指定位置（毫秒）
  Future<Duration> seek (Duration position) async {
    try {
      print("po"+position.toString());
      await Plugin.seek(position.inMilliseconds);

    } catch (e) {
      print('跳转失败: $e');
    }
    return Duration(seconds: 2);
  }

  // 释放资源
  void dispose() {
    // 释放流和其他资源
    progressNotifier.dispose();

  }
}