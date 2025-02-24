import 'dart:async';

import 'package:get/get.dart';
import 'package:music/app/global.dart';
import 'package:music/app/values/storage.dart';




/// 检查是否有 token
Future<bool> isAuthenticated() async {

  return true;
}

/// 删除缓存token
Future deleteAuthentication() async {

  Global.profile = null;
}

/// 重新登录
void deleteTokenAndReLogin() async {
  await deleteAuthentication();
  Get.offAndToNamed('/login');
}
