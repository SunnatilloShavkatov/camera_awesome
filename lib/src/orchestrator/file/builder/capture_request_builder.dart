import "package:camera_awesome/src/orchestrator/file/builder/capture_request_builder_stub.dart"
    if (dart.library.io) "capture_request_builder_io.dart"
    if (dart.library.html) "capture_request_builder_web.dart";
import "package:camera_awesome/src/orchestrator/models/capture_modes.dart";
import "package:camera_awesome/src/orchestrator/models/capture_request.dart";
import "package:camera_awesome/src/orchestrator/models/sensors.dart";

abstract class BaseCaptureRequestBuilder {
  Future<CaptureRequest> build({
    required CaptureMode captureMode,
    required List<Sensor> sensors,
  });
}

class AwesomeCaptureRequestBuilder {

  AwesomeCaptureRequestBuilder() : _fileBuilder = CaptureRequestBuilderImpl();
  final CaptureRequestBuilderImpl _fileBuilder;

  Future<CaptureRequest> build({
    required CaptureMode captureMode,
    required List<Sensor> sensors,
  }) => _fileBuilder.build(captureMode: captureMode, sensors: sensors);
}
