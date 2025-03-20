import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audio_metadata_extractor/audio_metadata_extractor.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:music/app/models/song.dart';
import 'package:music/app/routes/app_pages.dart';
import 'package:music/platform/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import  'package:dio/src/form_data.dart' as toData;
class RateLimiter {
  final int rateLimit; // 速率限制，单位秒
  int lastRequestTime = 0;

  RateLimiter(this.rateLimit);

  Future<void> waitIfNeeded() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeSinceLast = currentTime - lastRequestTime;

    if (timeSinceLast < rateLimit) {
      final waitTime = (rateLimit - timeSinceLast) * 1000;
      await Future.delayed(Duration(milliseconds: waitTime));
    }

    lastRequestTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
}



class Lanzhou {

  final String _processedSongListKey = 'processedSongListKey';

  static final Lanzhou _instance = Lanzhou._internal();

  factory Lanzhou() => _instance;

  Lanzhou._internal();

  late SharedPreferences _prefs;

  Future<List<Song>?> init() async {
    _prefs = await SharedPreferences.getInstance();
    List<Song>? songs;

    try {

      // 检查是否有处理后的数据缓存
     final processedSongListJson = _prefs.getString(_processedSongListKey);
      //final processedSongListJson =null;
      if (processedSongListJson != null) {
        // 如果有处理后的数据缓存，直接解析并返回
        final dynamic decodedList = jsonDecode(processedSongListJson);
        if (decodedList is List) {
          songs = decodedList
          //.whereType<Map<String, dynamic>>() // 过滤有效类型
              .map<Song>((dynamic item) => Song.fromJson(item))
              .toList();
        }
      } else {
        // 如果没有处理后的数据缓存，加载原始数据
        final rawSongList = await loadList();

        // 调用 fetchAndReadAudioMetadata 处理数据
        songs = [];
        for (var map in rawSongList) {
          try {
            final Song song = await fetchAndReadAudioMetadata(
                map['link']!, map['fileName']!);
            songs.add(song);
          } catch (e) {
            print('Error fetching metadata for ${map['filename']}: $e');
          }
        }

        // 将处理后的数据缓存到 SharedPreferences
        if (songs.isNotEmpty) {
          final processedSongListJson = jsonEncode(
              songs.map((song) => song.toJson()).toList());
          await _prefs.setString(_processedSongListKey, processedSongListJson);
        }
      }
    } catch (e, stackTrace) {
      print('初始化失败: $e');
      print('堆栈跟踪: $stackTrace');
    }

    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          // 超时异常处理
          print('拦截器捕获超时: ${error.message}');
          _prefs.clear();
          init();
        }
      },
    ));


    return songs; // 返回处理后的 List<Song>
  }




  Future<Song> fetchAndReadAudioMetadata(String furl, String filename) async {
    // 指定要下载的音频文件的URL
    final url = Uri.parse(furl);
    // 使用AudioMetadata.extractFromUri方法从URL中提取元数据
    final metadata = await AudioMetadata.extractFromUri(
        url, filename: filename);
    // 检查是否成功提取到元数据
    if (metadata != null) {
      // 打印提取到的元数据信息
      print("专辑: ${metadata.album}");
      print("主要艺术家: ${metadata.firstArtists}");
      print("次要艺术家: ${metadata.secondArtists}");
      print("曲目名称: ${metadata.trackName}");
      print("作曲者: ${metadata.composer}");
      print("封面大小: ${metadata.coverData?.length} 字节");
      final img = metadata.coverData;
      String base64Image = '';
      if (img != null) {
        base64Image = base64Encode(img);
      }
      var response = await dio.get(furl, options: Options(responseType: ResponseType.bytes), );


      var writeToFile = await Plugin.writeToFile(response.data, filename);
    /*  var file = File(writeToFile);
      var readAsBytes = await file.readAsString();
      print(readAsBytes);*/
      return Song(
        url: writeToFile,
        artist: metadata.firstArtists ?? "未知艺术家",
        title: metadata.trackName ?? '未知曲目',
        albumArtwork: base64Image,
        id:Random().nextInt(999).toString()
      );

    } else {
      print("未能提取到元数据");
      return Song(url: furl, title: _removeFileExtension(filename));
    }
  }

  String _removeFileExtension(String fileName) {
    final int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == 0) {
      // 如果没有找到点或者点在字符串开头，则返回原始文件名
      return fileName;
    }
    return fileName.substring(0, dotIndex);
  }


  Future<List<Map<String, String>>> loadList() async {
    const maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final link  = _prefs.getString('share_link');
        final password = _prefs.getString('share_password')  ;
        if(link == null || password == null) Get.toNamed(Routes.SETTINGS);
        final fileList = await getAllFileListByUrl(
        link!,
        pwd: password!,
        );


        final list = <Map<String, String>>[];
        for (final file in fileList) {
          final downloadLink = await getFinalLink(file['id']);
          list.add({
            "link": "$downloadLink",
            "fileName": (file['name_all']?.toString() ?? '未知文件'), // 确保字符串类型
          });
        }
        return list;
      } catch (e, stackTrace) {
        attempt++;
        print('加载失败 (尝试 $attempt/$maxRetries): $e');
        print('堆栈跟踪: $stackTrace');
        if (attempt >= maxRetries) {
          throw Exception('无法加载列表: $e');
        }
        await Future.delayed(Duration(seconds: attempt * 2)); // 指数退避
      }
    }
    return [];
  }


  final rateLimiter = RateLimiter(1);
  final dio = Dio(BaseOptions(
    headers: {
      'User-Agent':
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36',
    },
    connectTimeout: const Duration(seconds: 8), // 连接超时时间
    receiveTimeout: const Duration(seconds: 8), // 接收数据超时时间
    sendTimeout: const Duration(seconds: 8), // 发送数据超时时间
  ));

  Future<Map<String, dynamic>> prepareData(String url, String pwd,
      {int pg = 1}) async {
    final response = await dio.get(url);
    final scriptContent = response.data.toString();

    // 正则表达式匹配参数
    RegExp tRegex = RegExp(r"'t':([^,]+)");
    String? t = _extractVarValue(scriptContent, tRegex);

    RegExp kRegex = RegExp(r"'k':([^,]+)");
    String? k = _extractVarValue(scriptContent, kRegex);

    final fid = RegExp(r"'fid':(\d+)").firstMatch(scriptContent)?.group(1);
    final uid = RegExp(r"'uid':'([^']+)'").firstMatch(scriptContent)?.group(1);
    final lx = RegExp(r"'lx':(\d+)").firstMatch(scriptContent)?.group(1);
    final rep = RegExp(r"'rep':'([^']+)'").firstMatch(scriptContent)?.group(1);
    final up = RegExp(r"'up':(\d+)").firstMatch(scriptContent)?.group(1);
    final ls = RegExp(r"'ls':(\d+)").firstMatch(scriptContent)?.group(1);

    return {
      'lx': lx ?? '2',
      'fid': fid != null ? int.parse(fid) : 0,
      'uid': uid ?? '',
      'pg': pg,
      'rep': rep ?? '0',
      't': t ?? '',
      'k': k ?? '',
      'up': up ?? '1',
      'ls': ls ?? '1',
      'pwd': pwd
    };
  }

  String? _extractVarValue(String script, RegExp regex) {
    final match = regex.firstMatch(script);
    if (match == null) return null;

    final varName = match.group(1)?.replaceAll(RegExp(r"[\s']"), '');
    final varRegex = RegExp('var $varName = \'([^\']+)\'');
    return varRegex.firstMatch(script)?.group(1);
  }

  Future<List<dynamic>> getFileListByData(Map<String, dynamic> data,
      int pg) async {
    final url = 'https://wwjn.lanzout.com/filemoreajax.php?file=${data['fid']}';
    final formData = toData.FormData.fromMap({...data, 'pg': pg});

    try {
      final response = await dio.post(url, data: formData);
      if (response.statusCode == 401) {
        throw Exception('401: 请求过于频繁，请稍后再试');
      }

      // 检查 response.data 的类型
      dynamic jsonData;
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        jsonData = response.data;
      } else {
        throw Exception('未知的响应数据类型: ${response.data.runtimeType}');
      }

      if (jsonData['zt'] == 1) {
        return jsonData['text'];
      } else if (jsonData['zt'] == 2) {
        return [];
      }
      return [];
    } catch (e) {
      print('请求失败: $e');
      return [];
    }
  }

  Future<List<dynamic>> getAllFileListByUrl(String url,
      {String pwd = ''}) async {
    final data = await prepareData(url, pwd);
    final List<dynamic> result = [];
    int pg = 1;
    int retry = 0;

    while (retry <= 3) {
      await rateLimiter.waitIfNeeded();

      try {
        final list = await getFileListByData(data, pg);
        if (list.isEmpty) break;

        result.addAll(list);
        pg++;
        retry = 0;
      } catch (e) {
        retry++;
        print('获取列表失败，重试 $retry/3');
      }
    }

    return result;
  }

  Future<String?> getFinalLink(String id) async {
    try {
      final response = await dio.get('https://wwjn.lanzout.com/tp/$id');
      final doc = html_parser.parse(response.data);

      // 提取所有 <script> 标签的内容
      final scriptTags = doc.getElementsByTagName('script');
      String? vkjxld;
      String? hyggid;

      // 遍历所有 <script> 标签，查找目标变量
      for (var script in scriptTags) {
        final scriptContent = script.text;
        if (scriptContent.contains('var vkjxld')) {
          final match =
          RegExp(r"var vkjxld = '([^']+)';").firstMatch(scriptContent);
          if (match != null) {
            vkjxld = match.group(1);
          }
        }
        if (scriptContent.contains('var hyggid')) {
          final match =
          RegExp(r"var hyggid = '([^']+)';").firstMatch(scriptContent);
          if (match != null) {
            hyggid = match.group(1);
          }
        }
      }

      if (vkjxld == null || hyggid == null) {
        print('未找到 vkjxld 或 hyggid');
        return null;
      }

      // 拼接 URL 并获取最终下载链接
      final redirectUrl = '$vkjxld$hyggid';
      final redirectResponse =
      await dio.get(redirectUrl, options: Options(followRedirects: false));
      // final downloadPage = await getAllFileListByUrl(redirectResponse.data);
      final s = await getFinalLinkFromHtml(redirectResponse.data);
      // 解析下载页面，提取最终链接
      return s;
    } catch (e) {
      print('获取最终链接失败: $e');
      return null;
    }
  }

  Future<String?> getFinalLinkFromHtml(String htmlContent) async {
    final document = Document.html(htmlContent);

    // 查找所有的 <a> 标签
    final links = document.querySelectorAll('a');

    for (final link in links) {
      final href = link.attributes['href'];
      if (href != null && href.contains('.mp3')) {
        return href;
      }
    }

    return null;
  }
}
