import "dart:io";

import "package:camera_app/utils/file_utils.dart";
// import 'package:better_open_file/better_open_file.dart';
import "package:camera_awesome/camerawesome_plugin.dart";
import "package:camera_awesome/pigeon.dart";
import "package:cross_file/cross_file.dart";
import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";

void main() {
  runApp(const CameraAwesomeApp());
}

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
      title: "camerAwesome",
      home: CameraPage(),
    );
}

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      body: ColoredBox(
        color: Colors.white,
        child: CameraAwesomeBuilder.awesome(
          onMediaCaptureEvent: (MediaCapture event) {
            switch ((event.status, event.isPicture, event.isVideo)) {
              case (MediaCaptureStatus.capturing, true, false):
                debugPrint("Capturing picture...");
              case (MediaCaptureStatus.success, true, false):
                event.captureRequest.when(
                  single: (SingleCaptureRequest single) {
                    debugPrint("Picture saved: ${single.file?.path}");
                  },
                  multiple: (MultipleCaptureRequest multiple) {
                    multiple.fileBySensor.forEach((Sensor key, XFile? value) {
                      debugPrint("multiple image taken: $key ${value?.path}");
                    });
                  },
                );
              case (MediaCaptureStatus.failure, true, false):
                debugPrint("Failed to capture picture: ${event.exception}");
              case (MediaCaptureStatus.capturing, false, true):
                debugPrint("Capturing video...");
              case (MediaCaptureStatus.success, false, true):
                event.captureRequest.when(
                  single: (SingleCaptureRequest single) {
                    debugPrint("Video saved: ${single.file?.path}");
                  },
                  multiple: (MultipleCaptureRequest multiple) {
                    multiple.fileBySensor.forEach((Sensor key, XFile? value) {
                      debugPrint("multiple video taken: $key ${value?.path}");
                    });
                  },
                );
              case (MediaCaptureStatus.failure, false, true):
                debugPrint("Failed to capture video: ${event.exception}");
              default:
                debugPrint("Unknown event: $event");
            }
          },
          saveConfig: SaveConfig.photoAndVideo(
            photoPathBuilder: (List<Sensor> sensors) async {
              final Directory extDir = await getTemporaryDirectory();
              final Directory testDir = await Directory(
                "${extDir.path}/camerawesome",
              ).create(recursive: true);
              if (sensors.length == 1) {
                final String filePath =
                    "${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
                return SingleCaptureRequest(filePath, sensors.first);
              }
              // Separate pictures taken with front and back camera
              return MultipleCaptureRequest(
                <Sensor, String?>{
                  for (final Sensor sensor in sensors)
                    sensor:
                        '${testDir.path}/${sensor.position == SensorPosition.front ? 'front_' : "back_"}${DateTime.now().millisecondsSinceEpoch}.jpg',
                },
              );
            },
            videoOptions: VideoOptions(
              enableAudio: true,
              ios: CupertinoVideoOptions(
                fps: 10,
              ),
              android: AndroidVideoOptions(
                bitrate: 6000000,
                fallbackStrategy: QualityFallbackStrategy.lower,
              ),
            ),
            exifPreferences: ExifPreferences(saveGPSLocation: true),
          ),
          sensorConfig: SensorConfig.single(
            sensor: Sensor.position(SensorPosition.back),
            flashMode: FlashMode.auto,
          ),
          enablePhysicalButton: true,
          previewFit: CameraPreviewFit.contain,
          onMediaTap: (MediaCapture mediaCapture) {
            mediaCapture.captureRequest.when(
              single: (SingleCaptureRequest single) {
                debugPrint("single: ${single.file?.path}");
                single.file?.open();
              },
              multiple: (MultipleCaptureRequest multiple) {
                multiple.fileBySensor.forEach((Sensor key, XFile? value) {
                  debugPrint("multiple file taken: $key ${value?.path}");
                  value?.open();
                });
              },
            );
          },
          availableFilters: awesomePresetFiltersList,
        ),
      ),
    );
}
