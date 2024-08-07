// ignore_for_file: cascade_invocations, discarded_futures

import "dart:async";
import "dart:math";

import "package:camera_app/utils/mlkit_utils.dart";
import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";
import "package:google_mlkit_face_detection/google_mlkit_face_detection.dart";
import "package:rxdart/rxdart.dart";

/// This is an example using machine learning with the camera image
/// This is still in progress and some changes are about to come
/// - a provided canvas to draw over the camera
/// - scale and position points on the canvas easily (without calculating rotation, scale...)
/// ---------------------------
/// This use Google ML Kit plugin to process images on firebase
/// for more informations check
/// https://github.com/bharat-biradar/Google-Ml-Kit-plugin
void main() {
  runApp(const CameraAwesomeApp());
}

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: "camerAwesome App",
        home: CameraPage(),
      );
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final BehaviorSubject<FaceDetectionModel> _faceDetectionController =
      BehaviorSubject<FaceDetectionModel>();
  late Preview? _preview;

  final FaceDetectorOptions options = FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
  );
  late final FaceDetector faceDetector = FaceDetector(options: options);

  @override
  void deactivate() {
    faceDetector.close();
    super.deactivate();
  }

  @override
  void dispose() {
    _faceDetectionController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CameraAwesomeBuilder.previewOnly(
          previewFit: CameraPreviewFit.contain,
          sensorConfig: SensorConfig.single(
            sensor: Sensor.position(SensorPosition.front),
            aspectRatio: CameraAspectRatios.ratio_1_1,
          ),
          onImageForAnalysis: _analyzeImage,
          imageAnalysisConfig: AnalysisConfig(
            androidOptions: const AndroidAnalysisOptions.nv21(
              width: 250,
            ),
            maxFramesPerSecond: 5,
          ),
          builder: (CameraState state, Preview preview) {
            _preview = preview;
            return _MyPreviewDecoratorWidget(
              cameraState: state,
              faceDetectionStream: _faceDetectionController,
              preview: _preview!,
            );
          },
        ),
      );

  Future<void> _analyzeImage(AnalysisImage img) async {
    final InputImage inputImage = img.toInputImage();

    try {
      _faceDetectionController.add(
        FaceDetectionModel(
          faces: await faceDetector.processImage(inputImage),
          absoluteImageSize: inputImage.metadata!.size,
          rotation: 0,
          imageRotation: img.inputImageRotation,
          img: img,
        ),
      );
      // debugPrint("...sending image resulted with : ${faces?.length} faces");
    } on Exception catch (error) {
      debugPrint("...sending image resulted error $error");
    }
  }
}

class _MyPreviewDecoratorWidget extends StatelessWidget {
  const _MyPreviewDecoratorWidget({
    required this.cameraState,
    required this.faceDetectionStream,
    required this.preview,
  });

  final CameraState cameraState;
  final Stream<FaceDetectionModel> faceDetectionStream;
  final Preview preview;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: StreamBuilder<SensorConfig>(
          stream: cameraState.sensorConfig$,
          builder: (_, AsyncSnapshot<SensorConfig> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return StreamBuilder<FaceDetectionModel>(
                stream: faceDetectionStream,
                builder:
                    (_, AsyncSnapshot<FaceDetectionModel> faceModelSnapshot) {
                  if (!faceModelSnapshot.hasData) {
                    return const SizedBox();
                  }
                  // this is the transformation needed to convert the image to the preview
                  // Android mirrors the preview but the analysis image is not
                  final CanvasTransformation? canvasTransformation =
                      faceModelSnapshot.data!.img
                          ?.getCanvasTransformation(preview);
                  return CustomPaint(
                    painter: FaceDetectorPainter(
                      model: faceModelSnapshot.requireData,
                      canvasTransformation: canvasTransformation,
                      preview: preview,
                    ),
                  );
                },
              );
            }
          },
        ),
      );
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter({
    required this.model,
    this.canvasTransformation,
    this.preview,
  });

  final FaceDetectionModel model;
  final CanvasTransformation? canvasTransformation;
  final Preview? preview;

  @override
  void paint(Canvas canvas, Size size) {
    if (preview == null || model.img == null) {
      return;
    }
    // We apply the canvas transformation to the canvas so that the barcode
    // rect is drawn in the correct orientation. (Android only)
    if (canvasTransformation != null) {
      canvas.save();
      canvas.applyTransformation(canvasTransformation!, size);
    }
    for (final Face face in model.faces) {
      final Map<FaceContourType, Path> paths = <FaceContourType, Path>{
        for (final FaceContourType fct in FaceContourType.values) fct: Path(),
      };
      face.contours
          .forEach((FaceContourType contourType, FaceContour? faceContour) {
        if (faceContour != null) {
          paths[contourType]!.addPolygon(
            faceContour.points
                .map(
                  (Point<int> element) => preview!.convertFromImage(
                    Offset(element.x.toDouble(), element.y.toDouble()),
                    model.img!,
                  ),
                )
                .toList(),
            true,
          );
          for (final Point<int> element in faceContour.points) {
            final Offset position = preview!.convertFromImage(
              Offset(element.x.toDouble(), element.y.toDouble()),
              model.img!,
            );
            canvas.drawCircle(
              position,
              4,
              Paint()..color = Colors.blue,
            );
          }
        }
      });
      paths.removeWhere(
          (FaceContourType key, Path value) => value.getBounds().isEmpty,);
      for (final MapEntry<FaceContourType, Path> p in paths.entries) {
        canvas.drawPath(
          p.value,
          Paint()
            ..color = Colors.orange
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }
    }
    // if you want to draw without canvas transformation, use this:
    if (canvasTransformation != null) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) =>
      oldDelegate.model != model;
}

extension InputImageRotationConversion on InputImageRotation {
  double toRadians() {
    final int degrees = toDegrees();
    return degrees * 2 * pi / 360;
  }

  int toDegrees() {
    switch (this) {
      case InputImageRotation.rotation0deg:
        return 0;
      case InputImageRotation.rotation90deg:
        return 90;
      case InputImageRotation.rotation180deg:
        return 180;
      case InputImageRotation.rotation270deg:
        return 270;
    }
  }
}

@immutable
class FaceDetectionModel {
  const FaceDetectionModel({
    required this.faces,
    required this.absoluteImageSize,
    required this.rotation,
    required this.imageRotation,
    this.img,
  });

  final List<Face> faces;
  final Size absoluteImageSize;
  final int rotation;
  final InputImageRotation imageRotation;
  final AnalysisImage? img;

  Size get croppedSize => img!.croppedSize;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaceDetectionModel &&
          runtimeType == other.runtimeType &&
          faces == other.faces &&
          absoluteImageSize == other.absoluteImageSize &&
          rotation == other.rotation &&
          imageRotation == other.imageRotation &&
          croppedSize == other.croppedSize;

  @override
  int get hashCode =>
      faces.hashCode ^
      absoluteImageSize.hashCode ^
      rotation.hashCode ^
      imageRotation.hashCode ^
      croppedSize.hashCode;
}
