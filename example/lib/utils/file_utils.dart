import "dart:io";

import "package:better_open_file/better_open_file.dart";
import "package:camera_awesome/camerawesome_plugin.dart";
import "package:cross_file/cross_file.dart";
import "package:path_provider/path_provider.dart";

Future<String> path(CaptureMode captureMode) async {
  final Directory extDir = await getTemporaryDirectory();
  final Directory testDir =
      await Directory("${extDir.path}/test").create(recursive: true);
  final String fileExtension = captureMode == CaptureMode.photo ? "jpg" : "mp4";
  final String filePath =
      "${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension";
  return filePath;
}

extension XfileOpen on XFile {
  Future<void> open() async {
    final String spath = this.path;
    await OpenFile.open(spath);
  }
}
