// ignore_for_file: discarded_futures

import "dart:async";
import "dart:io";
import "dart:math";
import "dart:typed_data";

import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";
import "package:image/image.dart" as imglib;

void main() {
  runApp(const CameraAwesomeApp());
}

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: "CamerAwesome App - Filter example",
        home: CameraPage(),
      );
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final StreamController<AnalysisImage> _imageStreamController =
      StreamController<AnalysisImage>();

  @override
  void dispose() {
    _imageStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CameraAwesomeBuilder.analysisOnly(
          sensorConfig: SensorConfig.single(
            sensor: Sensor.position(SensorPosition.front),
            aspectRatio: CameraAspectRatios.ratio_1_1,
          ),
          onImageForAnalysis: (AnalysisImage img) async =>
              _imageStreamController.add(img),
          imageAnalysisConfig: AnalysisConfig(
            androidOptions: const AndroidAnalysisOptions.yuv420(
              width: 150,
            ),
            maxFramesPerSecond: 20,
          ),
          builder: (CameraState state, Preview preview) =>
              CameraPreviewDisplayer(
            analysisImageStream: _imageStreamController.stream,
          ),
        ),
      );
}

class CameraPreviewDisplayer extends StatefulWidget {
  const CameraPreviewDisplayer({
    super.key,
    required this.analysisImageStream,
  });

  final Stream<AnalysisImage> analysisImageStream;

  @override
  State<CameraPreviewDisplayer> createState() => _CameraPreviewDisplayerState();
}

class _CameraPreviewDisplayerState extends State<CameraPreviewDisplayer> {
  Uint8List? _cachedJpeg;

  @override
  Widget build(BuildContext context) => Center(
        child: StreamBuilder<AnalysisImage>(
          stream: widget.analysisImageStream,
          builder: (_, AsyncSnapshot<AnalysisImage> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final AnalysisImage img = snapshot.requireData;
            return img.when(
              jpeg: (JpegImage image) {
                _cachedJpeg = _applyFilterOnBytes(image.bytes);

                return ImageAnalysisPreview(
                  currentJpeg: _cachedJpeg!,
                  width: image.width.toDouble(),
                  height: image.height.toDouble(),
                );
              },
              yuv420: (Yuv420Image image) => FutureBuilder<JpegImage>(
                future: image.toJpeg(),
                builder: (_, AsyncSnapshot<JpegImage> snapshot) {
                  if (snapshot.data == null && _cachedJpeg == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.data != null) {
                    _cachedJpeg = _applyFilterOnBytes(
                      snapshot.data!.bytes,
                    );
                  }
                  return ImageAnalysisPreview(
                    currentJpeg: _cachedJpeg!,
                    width: image.width.toDouble(),
                    height: image.height.toDouble(),
                  );
                },
              ),
              nv21: (Nv21Image image) => FutureBuilder<JpegImage>(
                future: image.toJpeg(),
                builder: (_, AsyncSnapshot<JpegImage> snapshot) {
                  if (snapshot.data == null && _cachedJpeg == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.data != null) {
                    _cachedJpeg = _applyFilterOnBytes(
                      snapshot.data!.bytes,
                    );
                  }
                  return ImageAnalysisPreview(
                    currentJpeg: _cachedJpeg!,
                    width: image.width.toDouble(),
                    height: image.height.toDouble(),
                  );
                },
              ),
              bgra8888: (Bgra8888Image image) {
                // Conversion from dart directly
                _cachedJpeg = _applyFilterOnImage(
                  imglib.Image.fromBytes(
                    width: image.width,
                    height: image.height,
                    bytes: image.planes[0].bytes.buffer,
                    order: imglib.ChannelOrder.bgra,
                  ),
                );

                return ImageAnalysisPreview(
                  currentJpeg: _cachedJpeg!,
                  width: image.width.toDouble(),
                  height: image.height.toDouble(),
                );
                // We handle all formats so we're sure there won't be a null value
              },
            )!;
          },
        ),
      );

  Uint8List _applyFilterOnBytes(Uint8List bytes) =>
      _applyFilterOnImage(imglib.decodeJpg(bytes)!);

  Uint8List _applyFilterOnImage(imglib.Image image) => imglib.encodeJpg(
        imglib.billboard(image),
        quality: 70,
      );
}

class ImageAnalysisPreview extends StatelessWidget {
  const ImageAnalysisPreview({
    super.key,
    required this.currentJpeg,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;
  final Uint8List currentJpeg;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Colors.black,
        child: Transform.scale(
          scaleX: Platform.isAndroid ? -1 : null,
          child: Transform.rotate(
            angle: 3 / 2 * pi,
            child: SizedBox.expand(
              child: Image.memory(
                currentJpeg,
                gaplessPlayback: true,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
}
