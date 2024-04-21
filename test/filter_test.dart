import "dart:io";
import "dart:typed_data";

import "package:camera_awesome/src/photofilters/filters/filters.dart";
import "package:camera_awesome/src/photofilters/filters/preset_filters.dart";
import "package:flutter_test/flutter_test.dart";
import "package:image/image.dart";

void main() {
  const String src = "test/res/bird.jpg";

  for (final Filter filter in presetFiltersList) {
    test("Apply filter ${filter.name}", () async {
      final String dest = 'test/out/${filter.name.replaceAll(" ", "_")}.jpg';
      await File(dest).parent.create(recursive: true);

      final Image image = decodeImage(File(src).readAsBytesSync())!;
      final Uint8List pixels = image.getBytes();

      // Make treatment
      filter.apply(pixels, image.width, image.height);

      // Save image
      final Image out = Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: pixels.buffer,
      );
      File(dest).writeAsBytesSync(encodeNamedImage(dest, out)!);
    });
  }
}
