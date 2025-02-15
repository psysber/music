import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'soraplayer_platform_interface.dart';

/// An implementation of [SoraplayerPlatform] that uses method channels.
class MethodChannelSoraplayer extends SoraplayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sora_player_plugin');

  // 调用原生方法
  Future<void> showNotification(
    title,
    artist,
    imagePath,
    isPlaying,
  ) async {
    try {
      // 调用原生方法
      await methodChannel.invokeMethod('showNotification', {
        'title': title,
        'artist': artist,
        'imagePath': imagePath,
        'isPlaying': isPlaying,
      });
    } on PlatformException catch (e) {
      print("Failed to show notification: ${e.message}");
    }
  }
}
