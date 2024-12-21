
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Local_music{
 load_music() async {
  if (Platform.isAndroid) {
   var externalStorageDir = await getExternalStorageDirectory();
   if (externalStorageDir != null) {
    print('SD 卡根目录路径：${externalStorageDir.path}');
   } else {
    print('无法获取 SD 卡根目录。');
   }

  // listFilesInDirectory("/storage/emulated/0");
  }

 }



 Future<void> listFilesInDirectory(String directoryPath) async {
  final rootDirectory = Directory(directoryPath);
  if (rootDirectory.existsSync()) {
   final files = rootDirectory.listSync(recursive: true);
   for (final file in files) {
    if (file is File) {
     print('File: ${file.path}');
    } else if (file is Directory) {
     print('Directory: ${file.path}');
    }
   }
  } else {
   print('Root directory does not exist.');
  }
 }


}