import 'package:flutter_test/flutter_test.dart';
import 'package:soraplayer/soraplayer.dart';
import 'package:soraplayer/soraplayer_platform_interface.dart';
import 'package:soraplayer/soraplayer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSoraplayerPlatform
    with MockPlatformInterfaceMixin
    implements SoraplayerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<Map<String,dynamic>>> getMusicList() {

    MockSoraplayerPlatform fakePlatform = MockSoraplayerPlatform();
    SoraplayerPlatform.instance = fakePlatform;

    return fakePlatform.getMusicList();
  }
}

void main() {
  final SoraplayerPlatform initialPlatform = SoraplayerPlatform.instance;

  test('$MethodChannelSoraplayer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSoraplayer>());
  });

  test('getPlatformVersion', () async {
    Soraplayer soraplayerPlugin = Soraplayer();
    MockSoraplayerPlatform fakePlatform = MockSoraplayerPlatform();
    SoraplayerPlatform.instance = fakePlatform;

    expect(await soraplayerPlugin.getPlatformVersion(), '42');
  });
}
