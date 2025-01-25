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
      slivers: [  SliverFixedExtentList(
        itemExtent: 50.0,
        delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
            //创建列表项
            return Container(
              alignment: Alignment.center,
              color: Colors.lightBlue[100 * (index % 9)],
              child: Text('list item $index'),
            );
          },
          childCount: 20,
        ),
      ),],
    );
  }
}