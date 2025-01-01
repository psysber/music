import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:music/app/modules/home/modules/comm_appbar.dart';
import 'package:music/app/modules/home/modules/search_input.dart';

import '../controllers/discover_controller.dart';

class DiscoverView extends GetView<DiscoverController> {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    const str = "abcdefghizk";
    return CommAppbar(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
              height: 390.w,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "歌单列表",
                    style: TextStyle(fontSize: 32.sp),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    //padding: EdgeInsets.all(0.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //动态创建一个List<Widget>
                        children: str
                            .split("")
                            //每一个字母都用一个Text显示,字体为原来的两倍
                            .map((c) => Card(
                                  color: Colors.blue,
                                  child: SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: Text(c),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              )),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 590.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "最受欢迎",
                  style: TextStyle(fontSize: 32.sp),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(0.0),
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      //动态创建一个List<Widget>
                      children: str
                          .split("")
                          //每一个字母都用一个Text显示,字体为原来的两倍
                          .map((c) => Card(
                                color: Colors.blue,
                                child: SizedBox(
                                  width: 320,
                                  height: 260,
                                  child: Text(c),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 290,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text("排行榜",
                    style: TextStyle(fontSize: 32.sp),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(0.0),
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      //动态创建一个List<Widget>
                      children: str
                          .split("")
                          //每一个字母都用一个Text显示,字体为原来的两倍
                          .map((c) => Card(
                                color: Colors.blue,
                                child: SizedBox(
                                  width: 280,
                                  height: 240,
                                  child: Text(c),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
