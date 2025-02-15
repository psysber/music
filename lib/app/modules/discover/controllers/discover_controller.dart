import 'package:get/get.dart';
//import 'package:soraplayer/soraplayer.dart';

class DiscoverController extends GetxController {
  //TODO: Implement DiscoverController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
  /*  await Soraplayer().showNotification(
      title: 'Song Title',
      artist: 'Artist Name',
      imagePath:
          'https://img.moegirl.org.cn/common/thumb/c/c5/2020ismlhuangyu1.png/89px-2020ismlhuangyu1.png',
      isPlaying: true,
    );*/
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
