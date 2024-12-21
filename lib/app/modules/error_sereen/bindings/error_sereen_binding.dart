import 'package:get/get.dart';

import '../controllers/error_sereen_controller.dart';

class ErrorSereenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ErrorSereenController>(
      () => ErrorSereenController(),
    );
  }
}
