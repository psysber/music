import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:music/app/component/Img.dart';
import 'package:music/app/component/audio_manage.dart';
import 'package:music/app/component/scroll_text.dart';
import 'package:music/app/models/scroll_text.dart';
import 'package:music/app/models/song.dart';
import 'package:music/app/modules/home/controllers/home_controller.dart';
import 'package:music/app/modules/home/modules/play_list.dart';
import 'package:music/app/modules/home/views/home_view.dart';


class MusicNav extends GetView<HomeController> {

    bool _isNetworkUrl(String url) {
        return url.startsWith('http://') || url.startsWith('https://');
    }

    @override
    Widget build(BuildContext context) {
        final controller = Get.put(AudioManage());

        return GestureDetector(
            onHorizontalDragUpdate: (DragUpdateDetails h) {
                double dx = h.delta.dx;
                if (dx > 5) {
                    AudioManage().next();
                } else if (dx < -5) {
                    AudioManage().previous();
                }
                if(AudioManage().hasNext){
                    const SnackBar(content: Text("没有下一首了,亲!"),);
                }
                if(AudioManage().hasPrev){
                    const SnackBar(content: Text("没有上一首了,亲!"),);
                }
            },
            child: Container(
                height: 160.w,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const AudioProcessBar(),
                        const SizedBox(height: 5),
                        Row(
                            children: [
                                SizedBox(
                                    width: 100.w,
                                    height: 100.w,
                                    child: ClipOval(
                                        child: ValueListenableBuilder(
                                            valueListenable: controller
                                                .currentSongNotifier,
                                            builder: (_, song, __) {
                                                if (song != null) {
                                                    if (song.albumArtwork ==
                                                        '') {
                                                        return Image.asset(
                                                            "assets/images/loading.png");
                                                    }
                                                    if (_isNetworkUrl(song
                                                        .albumArtwork)) {
                                                        return Image.network(
                                                            song.albumArtwork);
                                                    } else {
                                                        final bytes = base64
                                                            .decode(
                                                            song.albumArtwork);
                                                        return Image.memory(
                                                            bytes);
                                                    }
                                                } else {
                                                    return Container();
                                                }
                                            })
                                    ),
                                ),
                                const SizedBox(width: 10),
                                ClipRect(
                                    child: ValueListenableBuilder(
                                        valueListenable: controller
                                            .currentSongNotifier,
                                        builder: (_, song, __) {
                                            if (song != null) {
                                                return SizedBox(
                                                    width: 320.w,
                                                    child: SmoothTextSwitcher(
                                                        texts: [
                                                            song.title,
                                                            song.artist
                                                        ]),);
                                            } else {
                                                return Container();
                                            }
                                        }) //
                                ),
                                // PreviousSongButton(),
                                PlayButton(),
                                IconButton(onPressed: (){
                                    if (Get.isBottomSheetOpen!) {
                                        // 如果底部弹窗已打开，则关闭
                                        Get.back();
                                       controller.isOpen.value = false;
                                    } else {
                                        // 否则打开底部弹窗
                                        Get.bottomSheet(
                                            isDismissible: true,
                                            const PlayList(),
                                            isScrollControlled: true,
                                        );
                                        controller.isOpen.value = true;
                                    }
                                }, icon: Icon(
                                  // 根据弹窗状态切换图标
                                  Icons.menu  ,
                                  size: 50.sp,
                                ))
                                // NextSongButton(),
                            ],
                        ),
                    ],
                )
            ),
        );
    }
}
