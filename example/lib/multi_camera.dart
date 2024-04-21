// ignore_for_file: discarded_futures

import "dart:io";
import "dart:math";

import "package:camera_app/utils/file_utils.dart";
import "package:camera_awesome/camerawesome_plugin.dart";
import "package:cross_file/cross_file.dart";
import "package:flutter/material.dart";
import "package:video_player/video_player.dart";

void main() {
  runApp(const CameraAwesomeApp());
}

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: "camerAwesome",
        // home: CameraPage(),
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == "/") {
            return MaterialPageRoute(
              builder: (BuildContext context) => const CameraPage(),
            );
          } else if (settings.name == "/gallery") {
            final MultipleCaptureRequest multipleCaptureRequest =
                settings.arguments! as MultipleCaptureRequest;
            return MaterialPageRoute(
              builder: (BuildContext context) => GalleryPage(
                multipleCaptureRequest: multipleCaptureRequest,
              ),
            );
          }
          return null;
        },
      );
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  SensorDeviceData? sensorDeviceData;
  bool? isMultiCamSupported;
  PipShape shape = PipShape.circle;

  @override
  void initState() {
    super.initState();

    CamerawesomePlugin.getSensors().then((SensorDeviceData value) {
      setState(() {
        sensorDeviceData = value;
      });
    });

    CamerawesomePlugin.isMultiCamSupported().then((bool value) {
      setState(() {
        debugPrint("📸 isMultiCamSupported: $value");
        isMultiCamSupported = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: ColoredBox(
        color: Colors.white,
        child: sensorDeviceData != null && isMultiCamSupported != null
            ? CameraAwesomeBuilder.awesome(
                saveConfig: SaveConfig.photoAndVideo(
                    // initialCaptureMode: CaptureMode.video,
                    ),
                sensorConfig: isMultiCamSupported ?? false
                    ? SensorConfig.multiple(
                        sensors: (Platform.isIOS)
                            ? <Sensor>[
                                Sensor.type(SensorType.telephoto),
                                Sensor.position(SensorPosition.front),
                              ]
                            : <Sensor>[
                                Sensor.position(SensorPosition.back),
                                Sensor.position(SensorPosition.front),
                              ],
                        flashMode: FlashMode.auto,
                        aspectRatio: CameraAspectRatios.ratio_16_9,
                      )
                    : SensorConfig.single(
                        sensor: Sensor.position(SensorPosition.back),
                        flashMode: FlashMode.auto,
                        aspectRatio: CameraAspectRatios.ratio_16_9,
                      ),
                // sensors: sensorDeviceData!.availableSensors
                //     .map((e) => Sensor.id(e.uid))
                //     .toList(),
                previewFit: CameraPreviewFit.fitWidth,
                onMediaTap: (MediaCapture mediaCapture) {
                  mediaCapture.captureRequest.when(
                    single: (SingleCaptureRequest single) =>
                        single.file?.open(),
                    multiple: (MultipleCaptureRequest multiple) =>
                        Navigator.of(context).pushNamed(
                      "/gallery",
                      arguments: multiple,
                    ),
                  );
                },
                pictureInPictureConfigBuilder: (int index, Sensor sensor) {
                  const double width = 300;
                  return PictureInPictureConfig(
                    startingPosition: Offset(
                      -50,
                      screenSize.height - 420,
                    ),
                    onTap: () {
                      debugPrint("on preview tap");
                    },
                    sensor: sensor,
                    pictureInPictureBuilder:
                        (Widget preview, double aspectRatio) => SizedBox(
                      width: width,
                      height: width,
                      child: ClipPath(
                        clipper: _MyCustomPipClipper(
                          width: width,
                          height: width * aspectRatio,
                          shape: shape,
                        ),
                        child: SizedBox(
                          width: width,
                          child: preview,
                        ),
                      ),
                    ),
                  );
                },
                previewDecoratorBuilder: (CameraState state, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      color: Colors.white70,
                      margin: const EdgeInsets.only(left: 8),
                      child: const Text("Change picture in picture's shape:"),
                    ),
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 16 / 9,
                      ),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: PipShape.values.length,
                      itemBuilder: (BuildContext context, int index) {
                        final PipShape shape = PipShape.values[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              this.shape = shape;
                            });
                          },
                          child: Container(
                            color: Colors.red.withOpacity(0.5),
                            margin: const EdgeInsets.all(8),
                            child: Center(
                              child: Text(
                                shape.name,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

enum PipShape {
  square,
  circle,
  roundedSquare,
  triangle,
  hexagon;

  Path getPath(Offset center, double width, double height) {
    switch (this) {
      case PipShape.square:
        return Path()
          ..addRect(
            Rect.fromCenter(
              center: center,
              width: min(width, height),
              height: min(width, height),
            ),
          );
      case PipShape.circle:
        return Path()
          ..addOval(
            Rect.fromCenter(
              center: center,
              width: min(width, height),
              height: min(width, height),
            ),
          );
      case PipShape.triangle:
        return Path()
          ..moveTo(center.dx, center.dy - min(width, height) / 2)
          ..lineTo(
            center.dx + min(width, height) / 2,
            center.dy + min(width, height) / 2,
          )
          ..lineTo(
            center.dx - min(width, height) / 2,
            center.dy + min(width, height) / 2,
          )
          ..close();
      case PipShape.roundedSquare:
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: center,
                width: min(width, height),
                height: min(width, height),
              ),
              const Radius.circular(20),
            ),
          );
      case PipShape.hexagon:
        return Path()
          ..moveTo(center.dx, center.dy - min(width, height) / 2)
          ..lineTo(
            center.dx + min(width, height) / 2,
            center.dy - min(width, height) / 4,
          )
          ..lineTo(
            center.dx + min(width, height) / 2,
            center.dy + min(width, height) / 4,
          )
          ..lineTo(center.dx, center.dy + min(width, height) / 2)
          ..lineTo(
            center.dx - min(width, height) / 2,
            center.dy + min(width, height) / 4,
          )
          ..lineTo(
            center.dx - min(width, height) / 2,
            center.dy - min(width, height) / 4,
          )
          ..close();
    }
  }
}

class _MyCustomPipClipper extends CustomClipper<Path> {
  const _MyCustomPipClipper({
    required this.width,
    required this.height,
    required this.shape,
  });

  final double width;
  final double height;
  final PipShape shape;

  @override
  Path getClip(Size size) => shape.getPath(
        size.center(Offset.zero),
        width,
        height,
      );

  @override
  bool shouldReclip(covariant _MyCustomPipClipper oldClipper) =>
      width != oldClipper.width ||
      height != oldClipper.height ||
      shape != oldClipper.shape;
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key, required this.multipleCaptureRequest});

  final MultipleCaptureRequest multipleCaptureRequest;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Gallery"),
        ),
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: widget.multipleCaptureRequest.fileBySensor.length,
          itemBuilder: (BuildContext context, int index) {
            final Sensor sensor =
                widget.multipleCaptureRequest.fileBySensor.keys.toList()[index];
            final XFile? file =
                widget.multipleCaptureRequest.fileBySensor[sensor];
            return GestureDetector(
              onTap: file?.open,
              child: file!.path.endsWith("jpg")
                  ? Image.file(
                      File(file.path),
                      fit: BoxFit.cover,
                    )
                  : VideoPreview(file: File(file.path)),
            );
          },
        ),
      );
}

class VideoPreview extends StatefulWidget {
  const VideoPreview({super.key, required this.file});

  final File file;

  @override
  State<StatefulWidget> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  Widget build(BuildContext context) => Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const SizedBox.shrink(),
      );
}
