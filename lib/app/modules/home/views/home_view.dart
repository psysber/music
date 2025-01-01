import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music/app/component/audio_manage.dart';
import 'package:music/app/component/notifiers/play_button_notifier.dart';
import 'package:music/app/component/notifiers/progress_notifier.dart';
import 'package:music/app/component/notifiers/repeat_button_notifier.dart';
import 'package:music/app/modules/discover/views/discover_view.dart';
import 'package:music/app/modules/home/controllers/home_controller.dart';
import 'package:music/app/modules/home/modules/music_nav.dart';
import 'package:music/app/modules/libary/views/library_view.dart';
import 'package:music/app/modules/local_music/views/local_music_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const tabs= [
      Tab(
        text: '推荐',
      ),
      Tab(
        text: '音乐库',
      ),
      Tab(
        text: '本地音乐',
      )
    ];
    return DefaultTabController(

        initialIndex: 0,
        length: tabs.length,
        child: Scaffold(
            drawerEnableOpenDragGesture: false,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(96.w),
              child: AppBar(
                title: null,
                automaticallyImplyLeading: false,
                bottom:  TabBar(
                  labelColor: const Color(0xff000000),
                  labelStyle: TextStyle(fontSize: 32.sp,fontWeight: FontWeight.bold),
                  unselectedLabelColor: const Color(0xff000000),
                  unselectedLabelStyle: TextStyle(fontSize: 26.sp),
                  isScrollable: true,
                  indicatorColor: const Color(0xff00BF00),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 3.0.w,
                  tabs:tabs
                ),
                centerTitle: true,
                backgroundColor: const Color(0xffffffff),
                elevation: 0,
              ),
            ),
            body: const TabBarView(
                children: [
              DiscoverView(),
              LibraryView(),
              LocalMusicView()
            ]),
            bottomNavigationBar: MusicNav()));
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
              fontSize: 10.sp, color: Theme.of(context).iconTheme.color),
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
