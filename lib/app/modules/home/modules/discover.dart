import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:music/app/modules/home/modules/search_input.dart';

//发现页
class Discover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
      child: CustomScrollView(slivers: <Widget>[
        SliverAppBar(

          automaticallyImplyLeading: false,
          pinned: true,
          // 滑动到顶端时会固定住
          expandedHeight: 20,
          flexibleSpace: Padding(
            padding: const EdgeInsets.all(10),
            child: SearchInput(),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("歌单列表"),
                 SingleChildScrollView(
                   scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(0.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //动态创建一个List<Widget>
                      children: str.split("")
                      //每一个字母都用一个Text显示,字体为原来的两倍
                          .map((c) => Card(color: Colors.blue,child: SizedBox(
                        width: 150,height: 130,child: Text(c),
                      ),))
                          .toList(),
                    ),
                  ),
                ),
              ],
            )
          ),
        ),
      ]),
    );
  }
}
