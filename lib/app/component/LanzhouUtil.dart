import 'dart:async';
import 'dart:io';


import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';



import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:logger/logger.dart';

class LanZouCloud {
    Dio dio = Dio();
  final Logger _logger = Logger();
  String? _cookie;
  final String _baseUrl = "https://pc.woozooo.com";
  final String  _shareUrl = "https://www.lanzoui.com";
  CookieManager ? _cookieManager;
  late CookieJar _cookieJar;
  static LanZouCloud _instance = LanZouCloud._internal();

  factory LanZouCloud() => _instance;
  LanZouCloud._internal() {
    // BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    BaseOptions options = new BaseOptions(
      // 请求基地址,可以包含子路径
      baseUrl: _baseUrl,

      //连接服务器超时时间，单位是毫秒.
      connectTimeout: Duration(seconds: 5),

      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: Duration(seconds: 5),

      // Http请求头.
      headers: {
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "zh-CN,zh-Hans;q=0.9",
        "Connection": "keep-alive",
        "Origin": "https://up.woozooo.com",
        "Referer": "https://up.woozooo.com/mlogin.php",
        "Sec-Fetch-Dest": "empty",
        "Sec-Fetch-Mode": "cors",
        "Sec-Fetch-Site": "same-origin",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Safari/605.1.15",
        "X-Requested-With": "XMLHttpRequest",
      },
      contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
      responseType: ResponseType.json,
    );

    dio = Dio(options);
    // 获取应用文档目录

    // 初始化 CookieJar
    _cookieJar = CookieJar();

    // 添加 CookieManager 拦截器
    dio.interceptors.add(CookieManager(_cookieJar));

    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      _logger.i(options);

      return handler.next(options); //continue
    }, onResponse: (response, handler) {
      _logger.i(response);
      return handler.next(response);
    }, onError: (DioException e, handler) {

       _logger.e(e);

      return handler.next(e);
    }));
  }



  /// 登录方法
  Future<void> login(String account,String password) async {
    const url = "https://up.woozooo.com/mlogin.php";
    final data = {
      "task": "3", // 登录任务标识
      "uid": account, // 账号
      "pwd": password, // 密码
      "setSessionId": "",
      "setSig": "",
      "setScene": "",
      "setToken": "",
      "formhash": "84c2b80e", // 表单哈希值（根据实际情况填写）
    };

    try {
      // 发送登录请求
      final response = await dio.post(url, data: data);

      // 检查登录是否成功
      if (response.data["zt"] != 1) {
        throw Exception("登录失败: ${response.data["info"]}");
      }
      _logger.i("登录成功: Cookie=$_cookie");
    } on DioException catch (e) {
      _logger.e("登录请求失败: ${e.message}");
      throw Exception("登录请求失败: ${e.message}");
    } catch (e) {
      _logger.e("登录失败: $e");
      throw Exception("登录失败: $e");
    }
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
      "task": 47,
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
        "task": 5,
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
      "task": 18,
      "file_id": fileId,
    };

    final response = await _post(url, data);
    return response.data["info"];
  }

  /// 通过 ID 获取文件分享地址
  Future<Map<String, dynamic>> getFileShareUrlById(String fileId) async {
    final url = "$_baseUrl/doupload.php";
    final data = {
      "task": 22,
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
      return await dio.post(url, data: data);

    } on DioException catch (e) {
      throw Exception("POST Request Error: ${e.message}");
    }
  }

  /// 发送 GET 请求
  Future<Response> _get(String url) async {
    try {
      return   await dio.get(url);
    } on DioException catch (e) {
      throw Exception("GET Request Error: ${e.message}");
    }
  }
}