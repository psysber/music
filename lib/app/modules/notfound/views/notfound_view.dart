import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/notfound_controller.dart';

class NotfoundView extends GetView<NotfoundController> {
  const NotfoundView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NotfoundView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'NotfoundView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
