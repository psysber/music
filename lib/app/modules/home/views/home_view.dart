import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:music/app/component/audio_manage.dart';
import 'package:music/app/component/notifiers/play_button_notifier.dart';
import 'package:music/app/component/notifiers/progress_notifier.dart';
import 'package:music/app/component/notifiers/repeat_button_notifier.dart';
import 'package:music/app/modules/home/modules/discover.dart';
import 'package:music/app/modules/home/modules/search_input.dart';


import '../controllers/home_controller.dart';


class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {


    return   DefaultTabController(
      //指定tabbar个数
        length: 1,
        initialIndex:0,
        child: Scaffold(
          drawerEnableOpenDragGesture: false,

          appBar: PreferredSize(preferredSize:Size.fromHeight(45.h) ,child: AppBar(
            title: null,
            automaticallyImplyLeading: false,
            bottom: const TabBar(

              labelColor: Color(0xff000000),
              labelStyle: TextStyle(fontSize: 19),
              unselectedLabelColor: Color(0xff000000),
              unselectedLabelStyle: TextStyle(fontSize: 13),
              isScrollable: true,
              indicatorColor: Color(0xff00BF00),
              indicatorSize:TabBarIndicatorSize.label,
              indicatorWeight:3.0,
              tabs: <Widget>[
                Tab(text: '推荐',),
              ],
            ),
            centerTitle: true,
            backgroundColor:Color(0xffffffff),
            elevation: 0,

          ),)
,

          body: TabBarView(
              children:   List<Container>.generate( 1, (i) {
                return Container(


                  child:  Discover(),
                );
              })

          ),

        )
    );

  }


}

class AudioProcessBar extends StatelessWidget {
  const AudioProcessBar({super.key});

  @override
  Widget build(BuildContext context) {
    final audioManage = AudioManage.instance;
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: AudioManage.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          barHeight: 3.0,
          thumbRadius: 5,
          thumbGlowRadius: 20,
          timeLabelTextStyle: TextStyle(
              fontSize: 10.sp,color: Theme.of(context).iconTheme.color),
          baseBarColor: const Color(0xFF120338),
          bufferedBarColor: const Color(0xFFD3ADF7),
          thumbColor: const Color(0xFF722ED1),
          progressBarColor: const Color(0xFFB37FEB),
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: audioManage.seek,
          timeLabelLocation: TimeLabelLocation.sides,
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  final audioManage = AudioManage.getInstance();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ValueListenableBuilder<bool>(
      valueListenable: AudioManage.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          onPressed: (isFirst) ? null : () => audioManage?.previous(),
          icon: const Icon(Icons.skip_previous_outlined),
        );
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  final audioManage = AudioManage.instance;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ValueListenableBuilder<bool>(
      valueListenable: AudioManage.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          onPressed: (isLast) ? null : audioManage.next,
          icon: const Icon(Icons.skip_next_outlined),
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  final audioManage = AudioManage.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: AudioManage.playButtonNotifier,
      builder: (BuildContext context, value, Widget? child) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 32.0.sp,
              height: 32.0.sp,
              child: const CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: AudioManage.instance.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(Icons.pause),
              onPressed: AudioManage.instance.pause,
            );
          default:
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: AudioManage.instance.play,
            );
        }
      },
    );
  }
}

class RepeatButton extends StatelessWidget {
  RepeatButton({Key? key}) : super(key: key);
  final audioManage = AudioManage.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RepeatState>(
      valueListenable: AudioManage.repeatButtonNotifier,
      builder: (context, value, child) {
        Icon icon;
        switch (value) {
          case RepeatState.repeatPlaylist:
            icon = const Icon(Icons.repeat);
            break;
          case RepeatState.off:
            icon = const Icon(Icons.shuffle);
            break;
          case RepeatState.repeatSong:
            icon = const Icon(Icons.repeat_one);
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: audioManage.repeat,
        );
      },
    );
  }
}


