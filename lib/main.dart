import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:music/app/modules/index/bindings/index_binding.dart';
import 'package:music/app/modules/index/views/index_view.dart';
import 'package:music/app/routes/app_pages.dart';
import 'package:soraplayer/soraplayer.dart';

void main() {
  runApp(const Music());
}

class Music extends StatelessWidget {
  const Music({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(750, 1134),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          defaultTransition: Transition.rightToLeftWithFade,
          title: 'KuYu music',
          home: IndexView(),
          initialBinding: IndexBinding(),
          debugShowCheckedModeBanner: false,
          enableLog: true,
          theme: ThemeData(
            primaryColor: Colors.deepPurpleAccent,
          ),
          darkTheme: ThemeData.light(useMaterial3: false),
          themeMode: ThemeMode.light,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          unknownRoute: AppPages.NOTFOUND,
          builder: EasyLoading.init(),
          // translations: TranslationService(),
          // locale: TranslationService.locale,
          // fallbackLocale: TranslationService.fallbackLocale,
          // darkTheme: dartTheme,
          // theme: lightTheme,
        );
      },
    );
  }
}
