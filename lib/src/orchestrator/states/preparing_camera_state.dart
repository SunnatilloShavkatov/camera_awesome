// ignore_for_file: public_member_api_docs, discarded_futures, flutter_style_todos
import "dart:async";
import "dart:io";

import "package:camera_awesome/camerawesome_plugin.dart";
import "package:camera_awesome/pigeon.dart";
import "package:camera_awesome/src/orchestrator/exceptions/camera_states_exceptions.dart";
import "package:camera_awesome/src/orchestrator/models/camera_physical_button.dart";

/// When is not ready
class PreparingCameraState extends CameraState {
  PreparingCameraState(
    super.cameraContext,
    this.nextCaptureMode, {
    this.onPermissionsResult,
  });

  /// this is the next state we are preparing to
  final CaptureMode nextCaptureMode;

  /// plugin user can execute some code once the permission has been granted
  final OnPermissionsResult? onPermissionsResult;

  @override
  CaptureMode? get captureMode => null;

  Future<void> start() async {
    final AwesomeFilter? filter = cameraContext.filterController.valueOrNull;
    if (filter != null) {
      await setFilter(filter);
    }
    switch (nextCaptureMode) {
      case CaptureMode.photo:
        await _startPhotoMode();
      case CaptureMode.video:
        await _startVideoMode();
      case CaptureMode.preview:
        await _startPreviewMode();
      case CaptureMode.analysis_only:
        await _startAnalysisMode();
    }
    await cameraContext.analysisController?.setup();
    if (nextCaptureMode == CaptureMode.analysis_only) {
      // Analysis controller needs to be setup before going to AnalysisCameraState
      await cameraContext.changeState(AnalysisCameraState.from(cameraContext));
    }

    if (cameraContext.enablePhysicalButton) {
      initPhysicalButton();
    }
  }

  /// subscription for permissions
  StreamSubscription? _permissionStreamSub;

  /// subscription for physical button
  StreamSubscription? _physicalButtonStreamSub;

  // FIXME: Remove enableImageStream & enablePhysicalButton options here
  Future<void> initPermissions(
    SensorConfig sensorConfig, {
    required bool enableImageStream,
    required bool enablePhysicalButton,
  }) async {
    // wait user accept permissions to init widget completely on android
    if (Platform.isAndroid) {
      _permissionStreamSub =
          CamerawesomePlugin.listenPermissionResult()!.listen(
        (bool res) {
          if (res && !_isReady) {
            _init(
              enableImageStream: enableImageStream,
              enablePhysicalButton: enablePhysicalButton,
            );
          }
          if (onPermissionsResult != null) {
            onPermissionsResult!(res);
          }
        },
      );
    }
    final List<CamerAwesomePermission>? grantedPermissions =
        await CamerawesomePlugin.checkAndRequestPermissions(
      cameraContext.exifPreferences.saveGPSLocation,
      checkMicrophonePermissions:
          cameraContext.initialCaptureMode == CaptureMode.video,
    );
    if (cameraContext.exifPreferences.saveGPSLocation &&
        !(grantedPermissions?.contains(CamerAwesomePermission.location) ??
            false)) {
      cameraContext.exifPreferences = ExifPreferences(saveGPSLocation: false);
      cameraContext.state.when(
          onPhotoMode: (PhotoCameraState pm) =>
              pm.shouldSaveGpsLocation(false));
    }
    if (onPermissionsResult != null) {
      onPermissionsResult?.call(
        grantedPermissions?.hasRequiredPermissions() ?? false,
      );
    }
  }

  void initPhysicalButton() {
    _physicalButtonStreamSub?.cancel();
    _physicalButtonStreamSub =
        CamerawesomePlugin.listenPhysicalButton()!.listen(
      (CameraPhysicalButton res) async {
        if (res == CameraPhysicalButton.volume_down ||
            res == CameraPhysicalButton.volume_up) {
          cameraContext.state.when(
            onPhotoMode: (PhotoCameraState pm) => pm.takePhoto(),
            onVideoMode: (VideoCameraState vm) => vm.startRecording(),
            onVideoRecordingMode: (VideoRecordingCameraState vrm) =>
                vrm.stopRecording(),
          );
        }
      },
    );
  }

  @override
  void setState(CaptureMode captureMode) {
    throw CameraNotReadyException(
      message:
          """You can't change current state while camera is in PreparingCameraState""",
    );
  }

  /////////////////////////////////////
  // PRIVATES
  /////////////////////////////////////

  Future<bool> _startVideoMode() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await _init(
      enableImageStream: cameraContext.imageAnalysisEnabled,
      enablePhysicalButton: cameraContext.enablePhysicalButton,
    );
    await cameraContext.changeState(VideoCameraState.from(cameraContext));

    return CamerawesomePlugin.start();
  }

  Future<bool> _startPhotoMode() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await _init(
      enableImageStream: cameraContext.imageAnalysisEnabled,
      enablePhysicalButton: cameraContext.enablePhysicalButton,
    );
    await cameraContext.changeState(PhotoCameraState.from(cameraContext));

    return CamerawesomePlugin.start();
  }

  Future<bool> _startPreviewMode() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await _init(
      enableImageStream: cameraContext.imageAnalysisEnabled,
      enablePhysicalButton: cameraContext.enablePhysicalButton,
    );
    await cameraContext.changeState(PreviewCameraState.from(cameraContext));

    return CamerawesomePlugin.start();
  }

  Future<bool> _startAnalysisMode() async {
    await Future<bool>.delayed(const Duration(milliseconds: 500));
    await _init(
      enableImageStream: cameraContext.imageAnalysisEnabled,
      enablePhysicalButton: cameraContext.enablePhysicalButton,
    );

    // On iOS, we need to start the camera to get the first frame because there
    // is no "AnalysisMode" at all.
    if (Platform.isIOS) {
      return CamerawesomePlugin.start();
    }
    return true;
  }

  bool _isReady = false;

  // TODO Refactor this (make it stream providing state)
  Future<bool> _init({
    required bool enableImageStream,
    required bool enablePhysicalButton,
  }) async {
    await initPermissions(
      sensorConfig,
      enableImageStream: enableImageStream,
      enablePhysicalButton: enablePhysicalButton,
    );
    await CamerawesomePlugin.init(
      sensorConfig,
      enableImageStream,
      enablePhysicalButton,
      captureMode: nextCaptureMode,
      exifPreferences: cameraContext.exifPreferences,
      videoOptions: saveConfig?.videoOptions,
      mirrorFrontCamera: saveConfig?.mirrorFrontCamera ?? false,
    );
    _isReady = true;
    return _isReady;
  }

  @override
  void dispose() {
    _permissionStreamSub?.cancel();
    _physicalButtonStreamSub?.cancel();
  }
}
