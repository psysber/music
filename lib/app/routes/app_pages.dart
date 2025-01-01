import 'package:get/get.dart';


import '../modules/discover/bindings/discover_binding.dart';
import '../modules/discover/views/discover_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/index/bindings/index_binding.dart';
import '../modules/index/views/index_view.dart';
import '../modules/local_music/bindings/local_music_binding.dart';
import '../modules/local_music/views/local_music_view.dart';
import '../modules/notfound/views/notfound_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;
  static final NOTFOUND = GetPage(
    name: Routes.NOTFOUND,
    page: () => NotfoundView(),
  );
  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.INDEX,
      page: () => IndexView(),
      binding: IndexBinding(),
    ),
    GetPage(
      name: _Paths.DISCOVER,
      page: () => const DiscoverView(),
      binding: DiscoverBinding(),
    ),
    GetPage(
      name: _Paths.LOCAL_MUSIC,
      page: () => const LocalMusicView(),
      binding: LocalMusicBinding(),
    ),
  ];
}
