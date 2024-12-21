import 'package:flutter/foundation.dart';

class PlayButtonNotifier extends ValueNotifier<ButtonState> {
  PlayButtonNotifier() : super(_initialValue);
  static const _initialValue = ButtonState.paused;
}

enum ButtonState {
  stopped, // 初始状态
  playing, // 正在播放
  paused, // 暂停
  completed, // 播放结束
  loading
}
