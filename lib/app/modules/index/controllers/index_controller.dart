import 'package:get/get.dart';

class IndexController extends GetxController {
  var isloadWelcomePage = true.obs;

  @override
  void onReady() {
    startCountdownTimer();
  }

  @override
  void onClose() {}

  // 展示欢迎页，倒计时1.5秒之后进入应用
  Future startCountdownTimer() async {
    await Future.delayed(const Duration(milliseconds: 1500), () {
      isloadWelcomePage.value = false;
    });
  }
}
