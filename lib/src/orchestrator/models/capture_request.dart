import "package:camera_awesome/src/orchestrator/models/sensors.dart";
import "package:cross_file/cross_file.dart";

abstract class CaptureRequest {
  const CaptureRequest();

  T when<T>({
    T Function(SingleCaptureRequest)? single,
    T Function(MultipleCaptureRequest)? multiple,
  }) {
    if (this is SingleCaptureRequest) {
      return single!(this as SingleCaptureRequest);
    } else if (this is MultipleCaptureRequest) {
      return multiple!(this as MultipleCaptureRequest);
    } else {
      throw Exception("Unknown CaptureResult type");
    }
  }

  String? get path;
}

class SingleCaptureRequest extends CaptureRequest {

  SingleCaptureRequest(String? filePath, this.sensor)
      : file = filePath == null ? null : XFile(filePath);
  final XFile? file;
  final Sensor sensor;

  @override
  String? get path => file?.path;
}

class MultipleCaptureRequest extends CaptureRequest {

  MultipleCaptureRequest(Map<Sensor, String?> filePathBySensor)
      : fileBySensor = <Sensor, XFile?>{
          for (final Sensor sensor in filePathBySensor.keys)
            sensor: filePathBySensor[sensor] != null
                ? XFile(filePathBySensor[sensor]!)
                : null,
        };
  final Map<Sensor, XFile?> fileBySensor;

  @override
  String? get path =>
      fileBySensor.values.firstWhere((XFile? element) => element != null)?.path;
}
