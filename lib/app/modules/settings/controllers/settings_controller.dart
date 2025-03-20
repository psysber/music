import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:music/app/component/lanzhou.dart';
import 'package:music/app/modules/cloud_music/controllers/cloud_music_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SettingsController extends GetxController {
  final TextEditingController linkController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool showPrompt = false.obs;
  final RxString promptText = ''.obs;
  final RxString buttonText = '返回'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
    // 监听输入变化
    linkController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    final bothEmpty = linkController.text.isEmpty && passwordController.text.isEmpty;
    buttonText.value = bothEmpty ? '返回' : '提交';
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    linkController.text = prefs.getString('share_link') ?? '';
    passwordController.text = prefs.getString('share_password') ?? '';
    _updateButtonState();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('share_link', linkController.text);
    await prefs.setString('share_password', passwordController.text);
  }

  Future<void> _showTypewriterEffect() async {
    var musicController = Get.put(CloudMusicController());
    const fullText = '分享更新成功';
    promptText.value = '';
    showPrompt.value = true;

    for (int i = 0; i < fullText.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        promptText.value = fullText.substring(0, i + 1);
      });
    }

    Future.delayed(Duration(milliseconds: 100 * fullText.length + 500), () {
      showPrompt.value = false;
    });

  }

  Future<void> handleButtonPress() async {
    if (buttonText.value == '提交') {
      await _saveData();
      _showTypewriterEffect();
      await Future.delayed(Duration(milliseconds: 1500));
      Get.back();
    } else {
      Get.back();
    }
  }
}