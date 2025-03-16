import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music/app/component/audio_manage.dart';
import 'package:music/app/component/notifiers/play_button_notifier.dart';
import 'package:music/app/models/song.dart';
import 'package:music/app/modules/home/modules/music_nav.dart';
import 'package:music/app/modules/home/views/home_view.dart';

import 'comm_appbar.dart';

class PlayList extends GetView<AudioManage>{
  const PlayList({super.key});

  void _handlePlayPause(int index, {bool flag = false}) {
    if (flag) {
      if (AudioManage().playButtonNotifier.value == ButtonState.paused) {
        AudioManage().playFromIndex(index);
      } else {
        AudioManage().pause();
      }
    } else {
      AudioManage().playFromIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {

    List list = AudioManage().getPlayList();

    Widget _buildSongTile(Song song, int index) {
      return Container(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () => _handlePlayPause(index,
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
                    onTap: () => _handlePlayPause(index,
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

   return Scaffold(
     backgroundColor: Colors.transparent,
     body:     Container(
    margin: EdgeInsets.only(top: 500.w),
     height: 700.w,
     decoration: const BoxDecoration(
       color: Colors.white,
       borderRadius:BorderRadius.all( Radius.circular(10.0)),
     ),
     //padding: EdgeInsets.only(bottom: 160.w),
     child: CustomScrollView(
       slivers: [
         SliverAppBar(
           expandedHeight: 100.w,
           pinned: true, // 滑动到顶端时会固定住
           automaticallyImplyLeading: false,
           backgroundColor: Colors.white,
           title: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text("播放列表",style: TextStyle(fontSize: 32.sp),),
               RepeatButton()

             ],
           ),
         ),
         SliverFixedExtentList(
           itemExtent: 170.0.w,
           delegate: SliverChildBuilderDelegate(
                   (BuildContext context, int index) {
                 final song = list[index];
                 return _buildSongTile(song, index);
               },
               childCount: controller.getPlayList().length
           ),
         ),
         //SliverPadding(padding: EdgeInsets.only(bottom: 100.w))
       ],
     ),
   ),
     bottomSheet: MusicNav(),
   );

  }

}