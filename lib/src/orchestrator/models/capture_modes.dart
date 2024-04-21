import "package:camera_awesome/camerawesome_plugin.dart";
import "package:camera_awesome/src/orchestrator/camera_context.dart";

enum CaptureMode {
  photo,
  video,
  preview,
  // ignore: constant_identifier_names
  analysis_only;

  CameraState toCameraState(CameraContext cameraContext) {
    if (this == CaptureMode.photo) {
      return PhotoCameraState.from(cameraContext);
    } else if (this == CaptureMode.video) {
      return VideoCameraState.from(cameraContext);
    } else if (this == CaptureMode.preview) {
      return PreviewCameraState(cameraContext: cameraContext);
    } else if (this == CaptureMode.analysis_only) {
      return AnalysisCameraState(cameraContext: cameraContext);
    }
    throw ArgumentError("State not recognized");
  }
}
