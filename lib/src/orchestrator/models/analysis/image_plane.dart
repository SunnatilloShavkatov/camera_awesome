import "dart:typed_data";

class ImagePlane {
  ImagePlane({
    required this.bytes,
    required this.bytesPerRow,
    required this.bytesPerPixel,
    required this.height,
    required this.width,
  });

  factory ImagePlane.from(Map<String, dynamic> map) => ImagePlane(
        bytes: map["bytes"],
        bytesPerRow: map["bytesPerRow"] ?? map["rowStride"],
        bytesPerPixel: map["pixelStride"],
        height: map["height"],
        width: map["width"],
      );
  Uint8List bytes;
  int bytesPerRow;
  int? bytesPerPixel;
  int? height;
  int? width;
}
