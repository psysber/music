import 'package:get/get.dart';

import '../controllers/local_music_controller.dart';

class LocalMusicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocalMusicController>(
      () => LocalMusicController(),
    );
  }
}
