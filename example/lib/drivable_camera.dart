import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";

class DrivableCamera extends StatelessWidget {

  const DrivableCamera({
    super.key,
    required this.saveConfig,
    required this.sensors,
  });
  final SaveConfig saveConfig;
  final List<Sensor> sensors;

  @override
  Widget build(BuildContext context) => MaterialApp(
      home: Scaffold(
        body: CameraAwesomeBuilder.awesome(
          saveConfig: saveConfig,
          onMediaTap: (MediaCapture media) {},
          sensorConfig: sensors.length == 1
              ? SensorConfig.single(sensor: sensors.first)
              : SensorConfig.multiple(sensors: sensors),
        ),
      ),
    );
}
