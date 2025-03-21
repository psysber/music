import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:music/app/component/audio_manage.dart';
import 'package:music/app/component/notifiers/play_button_notifier.dart';
import 'package:music/app/component/scroll_text.dart';
import 'package:music/app/models/song.dart';
import 'package:music/app/modules/home/modules/comm_appbar.dart';
import 'package:music/app/modules/home/views/home_view.dart';
import 'package:music/app/modules/local_music/controllers/local_music_controller.dart';
import 'package:music/platform/plugin_platform_interface.dart';

class LocalMusicView extends GetView<LocalMusicController> {
  const LocalMusicView({super.key});

  void _handlePlayPause(Song index, {bool flag = false}) {
    if (flag) {
      if (AudioManage().playButtonNotifier.value == ButtonState.paused) {
        AudioManage().play(index);
      } else {
        AudioManage().pause();
      }
    } else {
      AudioManage().play(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocalMusicController controller = Get.put(LocalMusicController());
    List list = controller.localSong;

    Widget _buildSongTile(Song song, int index) {
      return Container(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () => _handlePlayPause(song,
              flag:
                  song.title == AudioManage().currentSongNotifier.value?.title),
          child: ListTile(
            leading: Text('$index'),
            title: Text(
              song.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 32.sp),
            ),
            subtitle: Text(
              song.artist,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20.sp),
            ),
            trailing: SizedBox(
              height: double.infinity,
              width: 100.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () => _handlePlayPause(song,
                        flag: song.title ==
                            AudioManage().currentSongNotifier.value?.title),
                    child: ValueListenableBuilder(
                      valueListenable: AudioManage().currentSongNotifier,
                      builder: (_, value, __) {
                        if (value != null && song.title == value.title) {
                          return PlayButton();
                        } else {
                          return Icon(
                            Icons.play_circle_outline_rounded,
                            size: 40.sp,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Obx(() => CommAppbar(
          slivers: [
            SliverFixedExtentList(
              itemExtent: 170.0.w,
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final song = list[index];
                  return _buildSongTile(song, index);
                },
                childCount: controller.localSong.length,
              ),
            ),
          ],
        ));
  }
}
