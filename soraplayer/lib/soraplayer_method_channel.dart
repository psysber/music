import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'soraplayer_platform_interface.dart';

/// An implementation of [SoraplayerPlatform] that uses method channels.
class MethodChannelSoraplayer extends SoraplayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('soraplayer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future<List<dynamic>> getMusicList() async {
    final List<dynamic> result = await methodChannel.invokeMethod('queryLocalMusic');
    return result;
  }
}
