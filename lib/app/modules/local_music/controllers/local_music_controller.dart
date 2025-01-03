import 'package:get/get.dart';

import 'package:minio_new/minio.dart';
import 'package:music/app/utils/minio-utils.dart';

class LocalMusicController extends GetxController {
  final MinioUtils minioUtils = MinioUtils();
  final objects = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    fetchObjects();
  }

  void fetchObjects() async {}
}
