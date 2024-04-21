import "dart:typed_data";

import "package:camera_awesome/src/orchestrator/file/content/file_content.dart";
import "package:cross_file/cross_file.dart";

class FileContentImpl extends BaseFileContent {
  @override
  Future<Uint8List?> read(XFile file) => file.readAsBytes();

  @override
  Future<XFile?> write(XFile file, Uint8List bytes) async => XFile(file.path, bytes: bytes);
}
