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
    Get.put(DiscoverController());
    const str = "abcdefghizk";
    return CommAppbar(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
              height: 240.w,
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
                                    height: 160.w,
                                    child: Image.network(
                                      "https://img.moegirl.org.cn/common/thumb/c/c5/2020ismlhuangyu1.png/89px-2020ismlhuangyu1.png",
                                      fit: BoxFit.cover,
                                    ),
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
            height: 460.w,
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
                          .map((c) => SizedBox(
                              width: 320,
                              height: 410.w,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Image.network(
                                      "https://img.moegirl.org.cn/common/thumb/8/8f/时崎狂三-魔术侦探.jpeg/280px-时崎狂三-魔术侦探.jpeg",
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text("BAK SONG ss.."),
                                    subtitle: Text("ly-nsiwls"),
                                    trailing: Icon(Icons.headphones_rounded,
                                        size: 28),
                                  ),
                                  ListTile(
                                    leading: Image.network(
                                      "https://img.moegirl.org.cn/common/thumb/8/8f/时崎狂三-魔术侦探.jpeg/280px-时崎狂三-魔术侦探.jpeg",
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(
                                      "时崎狂三-魔术侦探.   BAK SONG ss..",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text("ly-nsiwls"),
                                    trailing: Icon(Icons.headphones_rounded,
                                        size: 28),
                                  ),
                                  ListTile(
                                    leading: Image.network(
                                      "https://img.moegirl.org.cn/common/thumb/8/8f/时崎狂三-魔术侦探.jpeg/280px-时崎狂三-魔术侦探.jpeg",
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text("BAK SONG ss.."),
                                    subtitle: Text("ly-nsiwls"),
                                    trailing: Icon(Icons.headphones_rounded,
                                        size: 28),
                                  ),
                                ],
                              )))
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
            height: 590.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "排行榜",
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
                                child: SizedBox(
                                  width: 280,
                                  height: 510.w,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: SizedBox(
                                          width: 260.w,
                                          height: 50.w,
                                          child: Row(children: [
                                            Text(
                                              "x榜单",
                                              style: TextStyle(fontSize: 34.sp),
                                            ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            Icon(Icons.play_circle)
                                          ]),
                                        ),
                                        trailing: Text("11.1.1 更新"),
                                      ),
                                      ListTile(
                                        leading: Image.network(
                                          "https://img.moegirl.org.cn/common/thumb/8/8f/时崎狂三-魔术侦探.jpeg/280px-时崎狂三-魔术侦探.jpeg",
                                          fit: BoxFit.cover,
                                        ),
                                        title: Text("BAK SONG ss.."),
                                        subtitle: Text("ly-nsiwls"),
                                        trailing: Icon(Icons.headphones_rounded,
                                            size: 28),
                                      ),
                                      ListTile(
                                        leading: Image.network(
                                          "https://img.moegirl.org.cn/common/thumb/8/8f/时崎狂三-魔术侦探.jpeg/280px-时崎狂三-魔术侦探.jpeg",
                                          fit: BoxFit.cover,
                                        ),
                                        title: Text(
                                          "时崎狂三-魔术侦探.   BAK SONG ss..",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text("ly-nsiwls"),
                                        trailing: Icon(Icons.headphones_rounded,
                                            size: 28),
                                      ),
                                      ListTile(
                                        leading: Image.network(
                                          "https://img.moegirl.org.cn/common/thumb/8/8f/时崎狂三-魔术侦探.jpeg/280px-时崎狂三-魔术侦探.jpeg",
                                          fit: BoxFit.cover,
                                        ),
                                        title: Text("BAK SONG ss.."),
                                        subtitle: Text("ly-nsiwls"),
                                        trailing: Icon(Icons.headphones_rounded,
                                            size: 28),
                                      ),
                                    ],
                                  ),
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
