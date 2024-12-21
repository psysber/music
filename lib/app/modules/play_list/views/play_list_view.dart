import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/play_list_controller.dart';

class PlayListView extends GetView<PlayListController> {
  const PlayListView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlayListView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'PlayListView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
