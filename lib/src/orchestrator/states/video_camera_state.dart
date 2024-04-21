import "dart:ui";

import "package:camera_awesome/camerawesome_plugin.dart";
import "package:camera_awesome/pigeon.dart";
import "package:camera_awesome/src/orchestrator/camera_context.dart";
import "package:collection/collection.dart";

/// When Camera is in Video mode
class VideoCameraState extends CameraState {
  VideoCameraState({
    required CameraContext cameraContext,
    required this.filePathBuilder,
  }) : super(cameraContext);

  factory VideoCameraState.from(CameraContext cameraContext) =>
      VideoCameraState(
        cameraContext: cameraContext,
        filePathBuilder: cameraContext.saveConfig!.videoPathBuilder!,
      );

  final CaptureRequestBuilder filePathBuilder;

  @override
  void setState(CaptureMode captureMode) {
    if (captureMode == CaptureMode.video) {
      return;
    }
    cameraContext.changeState(captureMode.toCameraState(cameraContext));
  }

  @override
  CaptureMode get captureMode => CaptureMode.video;

  /// You can listen to [cameraSetup.mediaCaptureStream] to get updates
  /// of the photo capture (capturing, success/failure)
  Future<CaptureRequest> startRecording() async {
    final CaptureRequest captureRequest =
        await filePathBuilder(sensorConfig.sensors.whereNotNull().toList());
    _mediaCapture = MediaCapture.capturing(
        captureRequest: captureRequest, videoState: VideoState.started,);
    try {
      await CamerawesomePlugin.recordVideo(captureRequest);
    } on Exception catch (e) {
      _mediaCapture =
          MediaCapture.failure(captureRequest: captureRequest, exception: e);
    }
    await cameraContext.changeState(VideoRecordingCameraState.from(cameraContext));
    return captureRequest;
  }

  /// If the video recording should [enableAudio].
  /// This method applies to the next recording. If a recording is ongoing, it will not be affected.
  // TODOAdd ability to mute temporarly a video recording
  Future<void> enableAudio(bool enableAudio) => CamerawesomePlugin.setAudioMode(enableAudio);

  /// PRIVATES

  set _mediaCapture(MediaCapture media) {
    if (!cameraContext.mediaCaptureController.isClosed) {
      cameraContext.mediaCaptureController.add(media);
    }
  }

  @override
  void dispose() {
    // Nothing to do
  }

  void focus() {
    cameraContext.focus();
  }

  Future<void> focusOnPoint({
    required Offset flutterPosition,
    required PreviewSize pixelPreviewSize,
    required PreviewSize flutterPreviewSize,
    AndroidFocusSettings? androidFocusSettings,
  }) => cameraContext.focusOnPoint(
      flutterPosition: flutterPosition,
      pixelPreviewSize: pixelPreviewSize,
      flutterPreviewSize: flutterPreviewSize,
      androidFocusSettings: androidFocusSettings,
    );
}
