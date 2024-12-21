import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/error_sereen_controller.dart';

class ErrorSereenView extends GetView<ErrorSereenController> {
  const ErrorSereenView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: const Center(
          child: Text("出错了"),
        ),
      )
    );
  }
}
