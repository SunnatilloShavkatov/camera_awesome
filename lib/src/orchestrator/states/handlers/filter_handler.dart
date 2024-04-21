// ignore_for_file: only_throw_errors
import "dart:io";
import "dart:isolate";
import "dart:typed_data";

import "package:camera_awesome/camerawesome_plugin.dart";
import "package:camera_awesome/src/orchestrator/file/content/file_content.dart";
import "package:cross_file/cross_file.dart";
import "package:image/image.dart" as img;

class FilterHandler {
  Isolate? photoFilterIsolate;

  Future<void> apply({
    required CaptureRequest captureRequest,
    required AwesomeFilter filter,
  }) async {
    if (Platform.isIOS && filter.id != AwesomeFilter.None.id) {
      photoFilterIsolate?.kill(priority: Isolate.immediate);

      final ReceivePort port = ReceivePort();
      photoFilterIsolate = await Isolate.spawn<PhotoFilterModel>(
        applyFilter,
        PhotoFilterModel(captureRequest, filter.output),
        onExit: port.sendPort,
      );
      await port.first;

      photoFilterIsolate?.kill(priority: Isolate.immediate);
    }
  }
}

Future<CaptureRequest> applyFilter(PhotoFilterModel model) async {
  final List<XFile?> files = model.captureRequest.when(
    single: (SingleCaptureRequest single) => <XFile?>[single.file],
    multiple: (MultipleCaptureRequest multiple) =>
        multiple.fileBySensor.values.toList(),
  );
  final FileContent fileContent = FileContent();
  for (final XFile? f in files) {
    // f is expected to not be null since the picture should have already been taken
    final img.Image? image = img.decodeJpg((await fileContent.read(f!))!);
    if (image == null) {
      throw MediaCapture.failure(
        exception: Exception("could not decode image ${f.path}"),
        captureRequest: model.captureRequest,
      );
    }

    final Uint8List pixels = image.getBytes();
    model.filter.apply(pixels, image.width, image.height);
    final img.Image out = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: pixels.buffer,
    );

    final List<int>? encodedImage = img.encodeNamedImage(f.path, out);
    if (encodedImage == null) {
      throw MediaCapture.failure(
        exception: Exception("could not encode image ${f.path}"),
        captureRequest: model.captureRequest,
      );
    }
    await fileContent.write(f, Uint8List.fromList(encodedImage));
  }
  return model.captureRequest;
}
