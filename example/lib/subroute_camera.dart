import "package:camera_app/utils/file_utils.dart";
import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";

// this example is based on the camerawesome issue
// check if memory increase when showing and hiding the camera multiple times
// https://github.com/Apparence-io/CamerAwesome/issues/242

void main() {
  runApp(const CameraAwesomeApp());
}

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: "camerAwesome",
      initialRoute: "emptyPage",
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case "cameraPage":
            return MaterialPageRoute(builder: (_) => const CameraPage());
          default:
            return MaterialPageRoute(builder: (_) => const EmptyPage());
        }
      },
    );
}

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: CameraAwesomeBuilder.awesome(
              saveConfig: SaveConfig.photoAndVideo(
                
              ),
              defaultFilter: AwesomeFilter.AddictiveRed,
              sensorConfig: SensorConfig.single(
                flashMode: FlashMode.auto,
                aspectRatio: CameraAspectRatios.ratio_16_9,
              ),
              previewFit: CameraPreviewFit.fitWidth,
              onMediaTap: (MediaCapture mediaCapture) {
                mediaCapture.captureRequest.when(
                  single: (SingleCaptureRequest single) => single.file?.open(),
                );
              },
            ),
          ),
          ElevatedButton(
            child: const Text("Go to empty page"),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "emptyPage");
            },
          ),
        ],
      ),
    );
}

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Empty Page"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Go to camera page"),
          onPressed: () {
            Navigator.pushReplacementNamed(context, "cameraPage");
          },
        ),
      ),
    );
}
