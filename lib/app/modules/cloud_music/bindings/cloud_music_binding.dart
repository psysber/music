import 'package:get/get.dart';

import '../controllers/cloud_music_controller.dart';

class CloudMusicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CloudMusicController>(
      () => CloudMusicController(),
    );
  }
}
