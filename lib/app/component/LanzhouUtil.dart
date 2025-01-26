import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LanZou {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  String? _cookie;
  String _baseUrl = "https://pc.woozooo.com";
  String _userAgent = "Your User Agent";
  String _uid = "13250233207";
  String _vei = "your_vei";

  LanZou() {
    _dio.options.headers = {
      "Referer": "https://pc.woozooo.com",
      "User-Agent": _userAgent,
    };
  }

  Future<Response> _post(String url, Map<String, dynamic> data) async {
    try {
      _logger.i("Sending POST request to $url with data: $data");
      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            "Cookie": _cookie ?? "", // 添加 Cookie
          },
        ),
      );
      _logger.i("Response received: ${response.data}");
      return response;
    } on DioError catch (e) {
      _logger
          .e("POST Request Error: ${e.message}, Response: ${e.response?.data}");
      throw Exception("POST Request Error: ${e.message}");
    }
  }

  Future<List<dynamic>> getAllFiles(String folderId) async {
    final folders = await getFolders(folderId);
    final files = await getFiles(folderId);
    return [...folders, ...files];
  }

  /// 通过 ID 获取文件夹
  Future<List<dynamic>> getFolders(String folderId) async {
    final url = "$_baseUrl/doupload.php";
    final data = {
      "task": "47",
      "folder_id": folderId,
    };

    final response = await _post(url, data);
    return response.data["text"];
  }

  /// 通过 ID 获取文件
  Future<List<dynamic>> getFiles(String folderId) async {
    final List<dynamic> files = [];
    int page = 1;

    while (true) {
      final url = "$_baseUrl/doupload.php";
      final data = {
        "task": "5",
        "folder_id": folderId,
        "pg": page.toString(),
      };

      final response = await _post(url, data);
      if (response.data["text"].isEmpty) {
        break;
      }

      files.addAll(response.data["text"]);
      page++;
    }

    return files;
  }

  /// 从响应头中提取 Cookie
  String _extractCookies(Headers headers) {
    final cookies = headers["set-cookie"];
    if (cookies == null || cookies.isEmpty) {
      throw Exception("未找到 Cookie");
    }
    return cookies.join(';');
  }

  /// 获取当前登录状态
  bool isLoggedIn() {
    return _cookie != null;
  }

  /// 获取 Cookie
  String? getCookie() {
    return _cookie;
  }
}
