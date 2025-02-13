import 'package:get/get.dart';
import 'package:music/platform/plugin_platform_interface.dart';


class LocalMusicController extends GetxController {
 /* void play() {
    Soraplayer().play("http://192.168.101.109:5000/HOYO-MiX-A%20Drowsy%20Sensation%20%E9%85%A3%E7%9D%A1%E7%9A%84%E9%83%81%E6%9E%97.mp3");
  }*/
  @override
  void onReady() {
    // TODO: implement onReady
    _setupListeners();
  }
  void _setupListeners() {
    Plugin.play('https://music.163.com/song/media/outer/url?id=31649312');


    Plugin.durationStream.listen((duration) {
      print('总时长: $duration 毫秒');
    });

    Plugin.completeStream.listen((_) {
      print('播放完成');
    });
    Plugin.positionStream.listen((position) {
      print('当前播放位置: $position 毫秒');
    });

  }



}
