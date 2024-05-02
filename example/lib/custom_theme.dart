// ignore_for_file: discarded_futures

import "package:camera_app/utils/file_utils.dart";
import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";

void main() {
  runApp(const CameraAwesomeApp());
}

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: "Themed CamerAwesome",
        home: CameraPage(),
      );
}

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CameraAwesomeBuilder.awesome(
          saveConfig: SaveConfig.photoAndVideo(),
          defaultFilter: AwesomeFilter.AddictiveRed,
          sensorConfig: SensorConfig.single(
            aspectRatio: CameraAspectRatios.ratio_1_1,
          ),
          previewFit: CameraPreviewFit.fitWidth,
          // Buttons of CamerAwesome UI will use this theme
          theme: AwesomeTheme(
            bottomActionsBackgroundColor: Colors.deepPurple.withOpacity(0.5),
            buttonTheme: AwesomeButtonTheme(
              backgroundColor: Colors.deepPurple.withOpacity(0.5),
              iconSize: 32,
              padding: const EdgeInsets.all(18),
              foregroundColor: Colors.lightBlue,
              // Tap visual feedback (ripple, bounce...)
              buttonBuilder: (Widget child, onTap) => ClipOval(
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    splashColor: Colors.deepPurple,
                    highlightColor: Colors.deepPurpleAccent.withOpacity(0.5),
                    onTap: onTap,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
          onMediaTap: (MediaCapture mediaCapture) {
            mediaCapture.captureRequest.when(
              single: (SingleCaptureRequest single) => single.file?.open(),
            );
          },
        ),
      );
}
