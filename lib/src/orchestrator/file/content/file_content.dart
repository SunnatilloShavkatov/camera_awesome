import "dart:typed_data";

import "package:camera_awesome/src/orchestrator/file/content/file_content_stub.dart"
    if (dart.library.io) "file_content_io.dart"
    if (dart.library.html) "file_content_web.dart";
import "package:cross_file/cross_file.dart";

abstract class BaseFileContent {
  Future<Uint8List?> read(XFile file);

  Future<XFile?> write(XFile file, Uint8List bytes);
}

class FileContent {

  FileContent() : _fileBuilder = FileContentImpl();
  final FileContentImpl _fileBuilder;

  Future<Uint8List?> read(XFile file) => _fileBuilder.read(file);

  Future<XFile?> write(XFile file, Uint8List bytes) => _fileBuilder.write(file, bytes);
}
