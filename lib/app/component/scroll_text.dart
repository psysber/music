import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/app/models/song.dart';

class ScrollTextController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> animation;
  
  @override
  void onInit() {
    super.onInit();
    // 初始化动画控制器和动画
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    animation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(-1.0, 0.0),
    ).animate(animationController);
    // 添加动画监听器以触发 UI 更新
    animation.addListener(() => update());
    // 循环播放动画
    animationController.repeat();
  }

  // 切换动画播放状态
  void toggleAnimation() {
    if (animationController.isAnimating) {
      animationController.stop();
    } else {
      animationController.repeat();
    }
  }

  @override
  void onClose() {
    animationController.dispose(); // 释放资源
    super.onClose();
  }
}




class ScrollText extends StatelessWidget {
  final String child;
  final TextStyle? style;

  const ScrollText({
    super.key,
    required this.child,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScrollTextController>(
      init: ScrollTextController(), // 初始化控制器
      builder: (controller) {

          return FractionalTranslation(
            translation: controller.animation.value, // 使用控制器中的动画值
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: InkWell(
                onTap: () => controller.toggleAnimation(), // 点击切换动画状态
                child: Text(
                  child,

                ),
              ),
            ),
          );

      },
    );
  }
}




