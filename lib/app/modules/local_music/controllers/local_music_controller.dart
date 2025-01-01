import 'package:get/get.dart';
import 'package:music/app/utils/minio-utils.dart';
class LocalMusicController extends GetxController {
  final MinioUtils minioUtils = MinioUtils();
  final objects = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchObjects();
  }

  void fetchObjects() async {
    final objectKeys = await minioUtils.listObjects('music');
    objects.assignAll(objectKeys);

  }
}
