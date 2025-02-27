import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music/app/component/LanzhouUtil.dart';
import 'package:music/app/component/audio_manage.dart';
import 'package:music/app/component/scroll_text.dart';
import 'package:music/app/models/song.dart';
import 'package:music/app/modules/home/modules/comm_appbar.dart';
import 'package:music/app/modules/local_music/controllers/local_music_controller.dart';
import 'package:music/platform/plugin_platform_interface.dart';

class LocalMusicView extends GetView<LocalMusicController> {
  const LocalMusicView({super.key});

  @override
  Widget build(BuildContext context) {
      final LocalMusicController controller = Get.put(LocalMusicController());
      List songs = controller.localSong;
     return Obx(()=>CommAppbar(
       slivers: [
         SliverFixedExtentList(
           itemExtent: 50.0,
           delegate: SliverChildBuilderDelegate(
                 (BuildContext context, int index) {
               //创建列表项
               Song song=songs[index];
               return ListTile(title: Text(song.title,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 28.sp),),
                 subtitle: Text("${song.artist}",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 20.sp),),
                 trailing: SizedBox(
                     height: 120.w,
                     width: 230.w,
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         InkWell(onTap: (){
                           AudioManage().play(song);
                         },
                           child: Icon(Icons.play_circle_outline_rounded),
                         ),
                         Icon(Icons.add_box_outlined),
                       ],
                     )
                 ),
               );
             },
             childCount: songs.length,
           ),
         ),
       ],
     ));


  }
}
