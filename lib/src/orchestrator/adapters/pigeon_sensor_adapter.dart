import 'package:camera_awesome/pigeon.dart';
import 'package:camera_awesome/src/orchestrator/models/sensors.dart';

extension PigeonSensorAdapter on Sensor {
  PigeonSensor toPigeon() {
    return PigeonSensor(
      position: position?.name != null
          ? PigeonSensorPosition.values.byName(position!.name)
          : PigeonSensorPosition.unknown,
      deviceId: deviceId,
      type: type?.name != null
          ? PigeonSensorType.values.byName(type!.name)
          : PigeonSensorType.unknown,
    );
  }
}
