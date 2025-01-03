import 'dart:io';

import 'package:minio_new/minio.dart';

class MinioUtils {
  final Minio _minio;

  MinioUtils()
      : _minio = Minio(
          endPoint: '127.0.0.1',
          port: 9001,
          useSSL: true,
          accessKey: '2ZALs7fWwaVCqE1TQX8x',
          secretKey: 'J9zghNgCdfW6QOqx6QcJuSjLJYjXpX4785n0ROrB',
        );

  Future<List<String>> listObjects(String bucket) async {
    final region = await _minio.getBucketRegion('music');
    print('--- object region:');
    print(region);
    return [];
  }

  Future<void> downloadObjects(
      String bucket, List<String> objectKeys, String downloadPath) async {
    for (final key in objectKeys) {
      final stream = await _minio.getObject(bucket, key);
      final file = File('$downloadPath/$key');
      await file.create(recursive: true);
      await stream.pipe(file.openWrite());
    }
  }
}
