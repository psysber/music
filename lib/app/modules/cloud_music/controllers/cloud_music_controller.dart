import 'dart:convert';



import 'package:get/get.dart';
import 'package:music/app/component/audio_manage.dart';
import 'package:music/app/component/lanzhou.dart';
import 'package:music/app/models/song.dart';
import 'package:shared_preferences/shared_preferences.dart';





class CloudMusicController extends GetxController with StateMixin<List<dynamic>>{
  var songList = <Song>[].obs;

  @override
  void onReady() async {
   loadData();
  }
  Future<void> loadData() async {

    change(null, status: RxStatus.loading());
    //_checkAndClearCache();
    // 获取原始数据
    final list = await Lanzhou().init();
    if(list!=null){
      // 更新 songList
      songList.assignAll(list);
      change(songList, status: RxStatus.success());

    } else {
      change(null, status: RxStatus.error('获取失败'));
    }
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    loadData();
    }






}





