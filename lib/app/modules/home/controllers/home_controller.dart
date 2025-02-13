
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
//数据

  @override
  onInit() {
    super.onInit();
  }

  @override
  void onReady() {
/*    AudioManage.instance.addPlaylists([
      MediaItem(
          id: "31649312",
          title: "EGOIST",
          album: "EGOSIT",
          extras: {
            'url': "https://music.163.com/song/media/outer/url?id=31649312",
            "singer": "EGOIST",
            "image":
                'https://jrocknews.com/wp-content/uploads/2017/11/egoist-greatest-hits-2011-2017-alter-ego-artwork-regular-edition.jpg'
          },
          artUri: Uri.tryParse(
              "https://jrocknews.com/wp-content/uploads/2017/11/egoist-greatest-hits-2011-2017-alter-ego-artwork-regular-edition.jpg"))
    ]);*/
  }

  @override
  void onClose() {
    super.onClose();
  }
}
