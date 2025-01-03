import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:music/app/component/swiper_view.dart';
import 'package:music/app/modules/home/modules/comm_appbar.dart';
import 'package:music/app/modules/libary/controllers/library_controller.dart';
import 'dart:math';

class LibraryView extends GetView<LibraryController> {
  const LibraryView({super.key});
  Color getRandomBrightColor() {
  Random random = Random();
  int r = 200 + random.nextInt(56); // 200-255
  int g = 200 + random.nextInt(56); // 200-255
  int b = 200 + random.nextInt(56); // 200-255
  return Color.fromRGBO(r, g, b, 0.7); // 50% 透明度
}
  @override
  Widget build(BuildContext context) {
    Get.put(LibraryController());
    final list=[
      {'item':"歌手",'icon':Icons.perm_contact_calendar_rounded},
      {'item':"排行",'icon':Icons.perm_contact_calendar_rounded},
      {'item':"歌单",'icon':Icons.perm_contact_calendar_rounded},
      {'item':"专辑",'icon':Icons.perm_contact_calendar_rounded},
      {'item':"歌手",'icon':Icons.perm_contact_calendar_rounded},
      {'item':"歌手",'icon':Icons.perm_contact_calendar_rounded},
      {'item':"歌手",'icon':Icons.perm_contact_calendar_rounded},
    ];

    final playlist = [
      {'image': 'https://www.itying.com/images/flutter/1.png','description': 'Playlist 1'},
      {'image': 'https://www.itying.com/images/flutter/2.png','description': 'Playlist 2'},
      {'image': 'https://www.itying.com/images/flutter/2.png','description': 'Playlist 2'},
      {'image': 'https://www.itying.com/images/flutter/2.png','description': 'Playlist 2'},
      {'image': 'https://www.itying.com/images/flutter/2.png','description': 'Playlist 2'},
      {'image': 'https://www.itying.com/images/flutter/2.png','description': 'Playlist 2'},
      
    ];

    return CommAppbar(
      slivers: [
        SliverToBoxAdapter(
            child: SizedBox(
                height: 500.w,
                child: SwiperView()
            )
        ),
        SliverPadding(padding: EdgeInsets.all(10.h)),
         
        SliverToBoxAdapter(
          child: SizedBox(
            height: 160.w ,
            child: ListView.builder(
               scrollDirection: Axis.horizontal,
                itemCount: list.length,
                itemExtent: 150.0.w, //强制高度为50.0
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(list[index]['icon'] as IconData?,size: 48.sp,),
                      Text(list[index]['item'] as String,style: TextStyle(fontSize: 32.sp),)
                    ],
                  );
                }
            )
          ),
        ),
        SliverToBoxAdapter(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '歌单推荐',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            // 在这里添加跳转逻辑
          },
        ),
      ],
    ),
  ),
),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 170.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: playlist.length,
              itemExtent: 150.0.h,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: NetworkImage(playlist[index]['image'] as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 40.h,
                        width: double.infinity,
                        color: getRandomBrightColor(),
                        child: Text(
                          playlist[index]['description'] as String,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                          
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
