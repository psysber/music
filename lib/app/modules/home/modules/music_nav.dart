import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music/app/component/Img.dart';
import 'package:music/app/component/scroll_text.dart';
import 'package:music/app/modules/home/views/home_view.dart';

class MusicNav extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return  Container(
        height: 160.w,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 50.w),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
           // AudioProcessBar(),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: ClipOval(
                    child: Img(
                        'https://jrocknews.com/wp-content/uploads/2017/11/egoist-greatest-hits-2011-2017-alter-ego-artwork-regular-edition.jpg'),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: ScrollText(
                      child: "AAAAAAAAAAAAAAAAA",
                    )),
              /*  PreviousSongButton(),
                PlayButton(),
                NextSongButton()*/
              ],
            ),
          ],
        ));
  }

}