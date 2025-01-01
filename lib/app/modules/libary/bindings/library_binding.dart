import 'package:get/get.dart';
import 'package:music/app/modules/libary/controllers/library_controller.dart';


class LibraryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LibraryController>(
      () => LibraryController(),
    );
  }
}
