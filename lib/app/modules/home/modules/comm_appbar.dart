
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music/app/modules/home/modules/search_input.dart';

class CommAppbar extends StatelessWidget{
  final  slivers;

  CommAppbar({this.slivers = const <Widget>[]});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:   EdgeInsets.only(left: 20.w, right: 20.w, bottom: 8.w),
        child: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white.withAlpha(100),
            automaticallyImplyLeading: false,
            pinned: false,
            expandedHeight: 20,
            flexibleSpace: Padding(
              padding: const EdgeInsets.all(10),
              child: SearchInput(),

            ),
          ),
          ...slivers
        ]));
  }

}