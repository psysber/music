import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'soraplayer_method_channel.dart';

abstract class SoraplayerPlatform extends PlatformInterface {
  /// Constructs a SoraplayerPlatform.
  SoraplayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static SoraplayerPlatform _instance = MethodChannelSoraplayer();

  /// The default instance of [SoraplayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelSoraplayer].
  static SoraplayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SoraplayerPlatform] when
  /// they register themselves.
  static set instance(SoraplayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<List<dynamic>> getMusicList() async  {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
