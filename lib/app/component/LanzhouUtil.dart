import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:path/path.dart' as path;

class LanZouCloud {
  static const int FAILED = -1;
  static const int SUCCESS = 0;
  static const int ID_ERROR = 1;
  static const int PASSWORD_ERROR = 2;
  static const int LACK_PASSWORD = 3;
  static const int ZIP_ERROR = 4;
  static const int MKDIR_ERROR = 5;
  static const int URL_INVALID = 6;
  static const int FILE_CANCELLED = 7;
  static const int PATH_ERROR = 8;
  static const int NETWORK_ERROR = 9;
  static const int CAPTCHA_ERROR = 10;
  static const int OFFICIAL_LIMITED = 11;

  http.Client _client;
  bool _limitMode;
  int _timeout;
  int _maxSize;
  List<int> _uploadDelay;
  String _hostUrl;
  String _douploadUrl;
  String _accountUrl;
  String _mydiskUrl;
  Map<String, String> _cookies;
  Map<String, String> _headers;

  LanZouCloud()
      : _client = http.Client(),
        _limitMode = true,
        _timeout = 15,
        _maxSize = 100,
        _uploadDelay = [0, 0],
        _hostUrl = 'https://www.lanzous.com',
        _douploadUrl = 'https://pc.woozooo.com/doupload.php',
        _accountUrl = 'https://pc.woozooo.com/account.php',
        _mydiskUrl = 'https://pc.woozooo.com/mydisk.php',
        _cookies = {},
        _headers = {
          'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36',
          'Referer': 'https://www.lanzous.com',
          'Accept-Language': 'zh-CN,zh;q=0.9',
        };

  Future<http.Response>? _get(String url, {Map<String, String>? headers}) {
    try {
      headers ??= _headers;
      return http.get(Uri.parse(url), headers: headers).timeout(Duration(seconds: _timeout));
    } catch (e) {
      return null;
    }
  }

  Future<http.Response>? _post(String url, Map<String, String> data, {Map<String, String>? headers}) {
    try {
      headers ??= _headers;
      return http.post(Uri.parse(url), body: data, headers: headers).timeout(Duration(seconds: _timeout));
    } catch (e) {
      return null;
    }
  }

  void ignoreLimits() {

    print("*** You have enabled the big file upload and filename disguise features ***");
    print("*** This means that you fully understand what may happen and still agree to take the risk ***");

    _limitMode = false;
  }

  int setMaxSize({int max_size = 100}) {
    if (max_size < 100) {
      return LanZouCloud.FAILED;
    }
    _maxSize = max_size;
    return LanZouCloud.SUCCESS;
  }

  int setUploadDelay(List<int> t_range) {
    if (t_range[0] >= 0 && t_range[0] <= t_range[1]) {
      _uploadDelay = t_range;
      return LanZouCloud.SUCCESS;
    }
    return LanZouCloud.FAILED;
  }
  Future<int> login(String username, String passwd) async {
    var loginData = {
      "action": "login",
      "task": "login",
      "setSessionId": "",
      "setToken": "",
      "setSig": "",
      "setScene": "",
      "username": username,
      "password": passwd
    };
    var phoneHeader = {
      "User-Agent":
      "Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/82.0.4051.0 Mobile Safari/537.36"
    };

    var html = await _get(_accountUrl);
    if (html == null) {
      return LanZouCloud.NETWORK_ERROR;
    }
    var formhash = RegExp(r'name="formhash" value="(.+?)"').firstMatch(html.body);
    if (formhash == null) {
      return LanZouCloud.FAILED;
    }
    loginData['formhash'] = formhash.group(1)!;
    html = await _post(_accountUrl, loginData, headers: phoneHeader);
    if (html == null) {
      return LanZouCloud.NETWORK_ERROR;
    }
    if (html.body.contains('登录成功')) {
      var cookies = html.headers['set-cookie'];
      print('Cookies: $cookies');

      return LanZouCloud.SUCCESS;
    } else {
      return LanZouCloud.FAILED;
    }
  }

}



