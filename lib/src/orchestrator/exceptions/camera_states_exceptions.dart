// You called an action you are not supposed to call while camera is loading
import "package:camera_awesome/camerawesome_plugin.dart";
import "package:camera_awesome/src/orchestrator/states/preparing_camera_state.dart";
import "package:camera_awesome/src/orchestrator/states/states.dart";

class CameraNotReadyException implements Exception {
  CameraNotReadyException({this.message});
  final String? message;

  @override
  String toString() => """
      CamerAwesome is not ready yet. 
      ==============================================================
      You must call start when current state is PreparingCameraState
      --------------------------------------------------------------
      additional informations: $message
    """;
}

/// from [PreparingCameraState] you must provide a valid next capture mode
class NoValidCaptureModeException implements Exception {}
