import "package:camera_app/drivable_camera.dart";
import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";

void main() {
  runApp(const CameraAwesomeApp());
}

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: "camerAwesome",
      home: DrivableCamera(
        saveConfig: SaveConfig.photo(),
        sensors: <Sensor>[
          Sensor.position(SensorPosition.back),
        ],
      ),
    );
}
