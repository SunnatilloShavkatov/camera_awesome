import "package:camera_awesome/pigeon.dart";
import "package:camera_awesome/src/orchestrator/models/sensors.dart";

class CameraCharacteristics {
  const CameraCharacteristics._();

  static Future<bool> isVideoRecordingAndImageAnalysisSupported(
    SensorPosition sensor,
  ) => CameraInterface().isVideoRecordingAndImageAnalysisSupported(
        PigeonSensorPosition.values.byName(sensor.name),);
}
