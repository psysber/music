import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:music/app/component/audio_manage.dart';
import 'package:music/app/component/notifiers/play_button_notifier.dart';
import 'package:music/app/models/song.dart';
import 'package:music/app/modules/home/modules/comm_appbar.dart';
import 'package:music/app/modules/home/views/home_view.dart';

import '../controllers/cloud_music_controller.dart';

class CloudMusicView extends GetView<CloudMusicController> {
  const CloudMusicView({super.key});
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
    final controller = Get.put(CloudMusicController());

    return controller.obx((list){

      Widget _buildSongTile(Song song, int index) {
        return Container(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () => _handlePlayPause(song),
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
                      onTap: () => _handlePlayPause(song),
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
      return Scaffold(
        body: CommAppbar(
          slivers: [
            SliverFixedExtentList(
              itemExtent: 170.0.w,
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  final song = list![index];
                  return _buildSongTile(song, index);
                },
                childCount: controller.songList.length,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.clear,
          child: Icon(Icons.refresh),
        ),
      );

    }, onLoading: Center(
      child: CircularProgressIndicator(),
    ),
      onError: (error) => Center(
          child: SizedBox(
            width: 500.w,
            height: 150.w,
            child: Column(
                children: [
                  Text("获取失败,点击重试"),
                  IconButton(onPressed:controller.clear, icon: Icon(Icons.refresh))
                ]),
          )


      ),
      onEmpty: Center(
        child: Text('暂无数据'),
      ),
    );







  }
}