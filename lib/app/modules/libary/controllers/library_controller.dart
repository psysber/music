import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:soraplayer/soraplayer.dart';


class LibraryController extends GetxController {

  var platformVersion = "Unknown";
  final _soraplayer = Soraplayer();
  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    initPlatformState();
    print("object");
  }

  Future<void> initPlatformState() async {

    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    var   result=await _soraplayer.getMusicList();
    print(result);

  }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.



  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
