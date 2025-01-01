import 'dart:async';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class SwiperView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _SwiperState();


}

class _SwiperState extends State<SwiperView> {
  List images = [
    //设置: 轮播图的图片素材
    "https://www.itying.com/images/flutter/1.png",
    "https://www.itying.com/images/flutter/2.png",
    "https://www.itying.com/images/flutter/3.png",
    "https://www.itying.com/images/flutter/4.png",
  ];

  @override
  Widget build(BuildContext context) {
    return   ClipRRect(
      borderRadius: BorderRadius.circular(5.0),


      child:  Swiper(
        itemBuilder: (context, index) {
          return Image.network(
            images[index],
            fit: BoxFit.fill,
          );
        },
        autoplay: true,
        itemCount: images.length,
        pagination: SwiperPagination(
            margin: EdgeInsets.zero,
            builder: SwiperCustomPagination(builder: (context, config) {
              return ConstrainedBox(
                constraints: const BoxConstraints.expand(height: 50.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: const DotSwiperPaginationBuilder(
                            color: Colors.grey,
                            activeColor: Colors.white,
                            size: 6.0,
                            activeSize: 8.0)
                            .build(context, config),
                      ),
                    )
                  ],
                ),
              );
            })),
        control: const SwiperControl(
            color: Colors.transparent
        ),
      ),
    );

  }
}
