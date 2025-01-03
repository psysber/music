import 'dart:async';
import 'dart:io';


import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';


import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:logger/logger.dart';

class LanZouCloud {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  String? _cookie;
  String _account;
  String _password;
  String _baseUrl = "https://pc.woozooo.com";
  String _shareUrl = "https://www.lanzoui.com";
  final CookieManager _cookieManager;

  LanZouCloud(this._account, this._password) : _cookieManager = CookieManager(CookieJar()) {
    _dio.interceptors.add(_cookieManager); // 添加 CookieManager
    _dio.options.headers = {
      "Accept": "application/json, text/javascript, */*; q=0.01",
      "Accept-Encoding": "gzip, deflate, br",
      "Accept-Language": "zh-CN,zh-Hans;q=0.9",
      "Connection": "keep-alive",
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
      "Origin": "https://up.woozooo.com",
      "Referer": "https://up.woozooo.com/mlogin.php",
      "Sec-Fetch-Dest": "empty",
      "Sec-Fetch-Mode": "cors",
      "Sec-Fetch-Site": "same-origin",
      "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Safari/605.1.15",
      "X-Requested-With": "XMLHttpRequest",
    };

  }

  /// 登录方法
  Future<void> login() async {
    const url = "https://up.woozooo.com/mlogin.php";
    final data = {
      "task": "3", // 登录任务标识
      "uid": _account, // 账号
      "pwd": _password, // 密码
      "setSessionId": "",
      "setSig": "",
      "setScene": "",
      "setToken": "",
      "formhash": "84c2b80e", // 表单哈希值（根据实际情况填写）
    };

    try {
      // 发送登录请求
      final response = await _dio.post(url, data: data);

      // 检查登录是否成功
      if (response.data["zt"] != 1) {
        throw Exception("登录失败: ${response.data["info"]}");
      }

      // 保存 Cookie
      _cookie = _extractCookies(response.headers);
      _logger.i("登录成功: Cookie=$_cookie");
    } on DioException catch (e) {
      _logger.e("登录请求失败: ${e.message}");
      throw Exception("登录请求失败: ${e.message}");
    } catch (e) {
      _logger.e("登录失败: $e");
      throw Exception("登录失败: $e");
    }
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

  /// 获取所有文件和文件夹
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

  /// 通过 ID 获取文件夹分享地址
  Future<Map<String, dynamic>> getFolderShareUrlById(String fileId) async {
    final url = "$_baseUrl/doupload.php";
    final data = {
      "task": "18",
      "file_id": fileId,
    };

    final response = await _post(url, data);
    return response.data["info"];
  }

  /// 通过 ID 获取文件分享地址
  Future<Map<String, dynamic>> getFileShareUrlById(String fileId) async {
    final url = "$_baseUrl/doupload.php";
    final data = {
      "task": "22",
      "file_id": fileId,
    };

    final response = await _post(url, data);
    return response.data["info"];
  }

  /// 通过分享链接获取文件或文件夹
  Future<List<dynamic>> getFileOrFolderByShareUrl(String shareId, String password) async {
    final pageData = await _getShareUrlHtml(shareId);
    if (!_isFile(pageData)) {
      return await _getFolderByShareUrl(password, pageData);
    } else {
      final file = await _getFilesByShareUrl(shareId, password, pageData);
      return [file];
    }
  }

  /// 判断是否为文件
  bool _isFile(String pageData) {
    return pageData.contains("class=\"fileinfo\"") ||
        pageData.contains("id=\"file\"") ||
        pageData.contains("文件描述");
  }

  /// 获取分享链接的 HTML 页面
  Future<String> _getShareUrlHtml(String shareId) async {
    final url = "$_shareUrl/$shareId";
    final response = await _get(url);
    return response.data;
  }

  /// 通过分享链接获取文件夹
  Future<List<dynamic>> _getFolderByShareUrl(String password, String pageData) async {
    final files = <dynamic>[];
    // 解析文件夹逻辑
    // TODO: 实现文件夹解析
    return files;
  }

  /// 通过分享链接获取文件
  Future<Map<String, dynamic>> _getFilesByShareUrl(String shareId, String password, String pageData) async {
    // 解析文件逻辑
    // TODO: 实现文件解析
    return {};
  }

  /// 发送 POST 请求
  Future<Response> _post(String url, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(url, data: data);
      _logger.d("POST Request: $url, Response: ${response.data}");
      return response;
    } on DioException catch (e) {
      _logger.e("POST Request Error: $url, Error: ${e.message}");
      throw Exception("POST Request Error: ${e.message}");
    }
  }

  /// 发送 GET 请求
  Future<Response> _get(String url) async {
    try {
      final response = await _dio.get(url);
      _logger.d("GET Request: $url, Response: ${response.data}");
      return response;
    } on DioException catch (e) {
      _logger.e("GET Request Error: $url, Error: ${e.message}");
      throw Exception("GET Request Error: ${e.message}");
    }
  }
}