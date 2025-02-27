import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:music/app/component/audio_manage.dart';
import 'package:music/app/models/song.dart';
import 'package:music/platform/plugin_platform_interface.dart';

class LocalMusicController extends GetxController {
  var localSong = <Song>[].obs;

  @override
  void onReady() {
    Plugin.fetchLocalSongs();
  }

}
