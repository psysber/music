import 'package:get/get.dart';
import 'package:music/app/modules/home/bindings/home_binding.dart';
import 'package:music/app/modules/home/views/home_view.dart';
import 'package:music/app/modules/index/bindings/index_binding.dart';
import 'package:music/app/modules/index/views/index_view.dart';
import 'package:music/app/modules/notfound/views/notfound_view.dart';

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
  ];
}
