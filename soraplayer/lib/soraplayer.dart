
import 'soraplayer_platform_interface.dart';

class Soraplayer {
  Future<String?> getPlatformVersion() {
    return SoraplayerPlatform.instance.getPlatformVersion();
  }
  Future<List<dynamic>> getMusicList() async  {
    return SoraplayerPlatform.instance.getMusicList();
  }
}
