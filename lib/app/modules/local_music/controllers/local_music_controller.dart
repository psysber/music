import 'package:get/get.dart';
import 'package:music/app/component/audio_manage.dart';
import 'package:music/app/models/song.dart';
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
  /*   await _methodChannel.invokeMethod('play', {
            'url': 'https://music.163.com/song/media/outer/url?id=31649312',
            'title': 'エゴイスト',
            'artist': 'EGOIST',
            'album' : 'エゴイスト',
            'artwork': 'https://ts4.cn.mm.bing.net/th?id=OIP-C.nVIDV_6Hl7cjQRevDFHdPAHaEf&w=80&h=80&c=1&vt=10&bgcl=ea0e6f&r=0&o=6&pid=5.1',
        });*/



  void _setupListeners() {

    var song = Song(
        title: "エゴイスト",
        artist: "EGOIST",
         albumTitle: "エゴイスト",
        albumArtwork: "https://jrocknews.com/wp-content/uploads/2017/11/egoist-greatest-hits-2011-2017-alter-ego-artwork-regular-edition.jpg",
        url: "https://music.163.com/song/media/outer/url?id=31649312"
    );
    AudioManage().play(song);

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