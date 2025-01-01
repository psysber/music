 import 'package:minio/minio.dart';
 import 'dart:io';

class MinioUtils {
  final Minio _minio;

  MinioUtils()
      : _minio = Minio(
          endPoint: '192.168.8.248',
          port: 9001,
          useSSL: false,
          accessKey: '2ZALs7fWwaVCqE1TQX8x',
          secretKey: 'J9zghNgCdfW6QOqx6QcJuSjLJYjXpX4785n0ROrB',
        );

  Future<List<String>> listObjects(String bucket) async {
    final objects = await _minio.listObjects(bucket).toList();
    print("ex");
    for (final obj in objects) {
      print(obj);
    }
    return [];
  }

  Future<void> downloadObjects(String bucket, List<String> objectKeys, String downloadPath) async {
    for (final key in objectKeys) {
      final stream = await _minio.getObject(bucket, key);
      final file = File('$downloadPath/$key');
      await file.create(recursive: true);
      await stream.pipe(file.openWrite());
    }
  }
}