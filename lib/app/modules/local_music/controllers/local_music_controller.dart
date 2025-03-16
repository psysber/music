import 'dart:io';
import 'dart:typed_data';


import 'package:audio_metadata_extractor/audio_metadata_extractor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:music/app/component/audio_manage.dart';
import 'package:music/app/models/song.dart';
import 'package:music/platform/plugin_platform_interface.dart';

class LocalMusicController extends GetxController {
  var localSong = <Song>[].obs;

  @override
  Future<void> onReady() async {
    localSong.clear();
    await Plugin.fetchLocalSongs();

  }
  @override
  Future<void> onClose() async {
    AudioManage().clearPlayList();
    await Plugin.fetchLocalSongs();
  }


}
