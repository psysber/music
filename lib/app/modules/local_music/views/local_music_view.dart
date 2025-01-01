import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/local_music_controller.dart';

class LocalMusicView extends GetView<LocalMusicController> {
  const LocalMusicView({super.key});

  @override
  Widget build(BuildContext context) {
      final LocalMusicController controller = Get.put(LocalMusicController());

    return Scaffold(
      body: Obx(() {
        if (controller.objects.isEmpty) {
          return const Center(
            child: Text(
              'No objects found',
              style: TextStyle(fontSize: 20),
            ),
          );
        } else {
          return ListView.builder(
            itemCount: controller.objects.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(controller.objects[index]),
              );
            },
          );
        }
      }),
    );
  }
}
