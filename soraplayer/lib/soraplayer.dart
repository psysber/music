import 'soraplayer_platform_interface.dart';

class Soraplayer {
  Future<String?> getPlatformVersion() {
    return SoraplayerPlatform.instance.getPlatformVersion();
  }

  Future<List<dynamic>> getMusicList() async {
    return SoraplayerPlatform.instance.getMusicList();
  }

  Future<void> showNotification(
      {required String title,
      required String artist,
      required String imagePath,
      required bool isPlaying}) {
    return SoraplayerPlatform.instance
        .showNotification(title, artist, imagePath, isPlaying);
  }
}
