import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:music/app/modules/home/modules/comm_appbar.dart';

import '../controllers/cloud_music_controller.dart';

class CloudMusicView extends GetView<CloudMusicController> {
  const CloudMusicView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CloudMusicController());

    return CommAppbar(
      slivers: [],
    );
  }
}