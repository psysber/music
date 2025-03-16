import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../controllers/settings_controller.dart';


class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => AnimatedOpacity(
            opacity: controller.showPrompt.value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              controller.promptText.value,
              style: TextStyle(fontSize: 24.sp),
            ),
          )),

          // 圆形输入框
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
            child: TextField(
              controller: controller.linkController,
              decoration: InputDecoration(
                hintText: '请输入分享链接',
                hintStyle: TextStyle(color: Colors.black38, fontSize: 28.sp),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w, vertical: 20.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(60.sp),
                  borderSide: const BorderSide(),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),

          // 圆形密码框
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
            child: TextField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '请输入分享密码',
                hintStyle: TextStyle(color: Colors.black38, fontSize: 28.sp),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w, vertical: 20.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(60.sp),
                  borderSide: const BorderSide(),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),

          SizedBox(height: 30.h),

          Obx(() => ElevatedButton(
            onPressed: controller.handleButtonPress,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.sp),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 50.w, vertical: 20.h),
            ),
            child: Text(
              controller.buttonText.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.sp,
              ),
            ),
          )),
        ],
      ),
    );
  }
}