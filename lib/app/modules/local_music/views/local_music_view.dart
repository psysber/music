import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/app/component/LanzhouUtil.dart';
import '../controllers/local_music_controller.dart';

class LocalMusicView extends GetView<LocalMusicController> {
  const LocalMusicView({super.key});

  @override
  Widget build(BuildContext context) {
      final LocalMusicController controller = Get.put(LocalMusicController());

    return Center(
      child: ElevatedButton(onPressed: (){
        LanZouCloud('13250233207', "hao123cc").getAllFiles('-1');
      }, child: Text("loging")),
    );
  }
}
