// ignore_for_file: comment_references, only_throw_errors, flutter_style_todos
import "dart:async";
import "dart:io";

import "package:camera_awesome/camerawesome_plugin.dart";
import "package:camera_awesome/pigeon.dart";
import "package:camera_awesome/src/logger.dart";
import "package:camera_awesome/src/orchestrator/adapters/pigeon_sensor_adapter.dart";
import "package:camera_awesome/src/orchestrator/models/camera_physical_button.dart";
import "package:collection/collection.dart";
import "package:cross_file/cross_file.dart";
import "package:flutter/services.dart";

export "src/camera_characteristics/camera_characteristics.dart";
export "src/orchestrator/analysis/analysis_controller.dart";
export "src/orchestrator/analysis/analysis_to_image.dart";
export "src/orchestrator/models/analysis/analysis_canvas.dart";

// filters
export "src/orchestrator/models/filters/awesome_filters.dart";
export "src/orchestrator/models/models.dart";
export "src/orchestrator/models/sensor_type.dart";
export "src/orchestrator/models/sensors.dart";
export "src/orchestrator/states/states.dart";
export "src/widgets/camera_awesome_builder.dart";

// built in widgets
export "src/widgets/widgets.dart";

// ignore: public_member_api_docs
enum CameraRunningState { starting, started, stopping, stopped }

/// Don't use this class directly. Instead, use [CameraAwesomeBuilder].
sealed class CamerawesomePlugin {
  CamerawesomePlugin._();

  static const EventChannel _orientationChannel =
      EventChannel("camerawesome/orientation");

  static const EventChannel _permissionsChannel =
      EventChannel("camerawesome/permissions");

  static const EventChannel _imagesChannel =
      EventChannel("camerawesome/images");

  static const EventChannel _physicalButtonChannel =
      EventChannel("camerawesome/physical_button");

  static Stream<CameraOrientations>? _orientationStream;

  static Stream<CameraPhysicalButton>? _physicalButtonStream;

  static Stream<bool>? _permissionsStream;

  static Stream<Map<String, dynamic>>? _imagesStream;

  static CameraRunningState currentState = CameraRunningState.stopped;

  /// Set it to true to print dart logs from camerawesome
  static bool printLogs = false;

  static Future<bool?> checkiOSPermissions(
    List<String?> permissionsName,
  ) async {
    final List<String?> permissions =
        await CameraInterface().checkPermissions(permissionsName);
    return permissions.isEmpty;
  }

  static Future<bool> start() async {
    if (currentState == CameraRunningState.started ||
        currentState == CameraRunningState.starting) {
      return true;
    }
    currentState = CameraRunningState.starting;
    final bool res = await CameraInterface().start();
    if (res) {
      currentState = CameraRunningState.started;
    }
    return res;
  }

  static Future<bool> stop() async {
    if (currentState == CameraRunningState.stopped ||
        currentState == CameraRunningState.stopping) {
      return true;
    }
    _orientationStream = null;
    currentState = CameraRunningState.stopping;
    bool res;
    try {
      res = await CameraInterface().stop();
    } on Exception catch (e) {
      return false;
    }
    currentState = CameraRunningState.stopped;
    return res;
  }

  static Stream<CameraOrientations>? getNativeOrientation() =>
      _orientationStream ??= _orientationChannel
          .receiveBroadcastStream("orientationChannel")
          .transform(
        StreamTransformer<dynamic, CameraOrientations>.fromHandlers(
          handleData: (data, EventSink<CameraOrientations> sink) {
            CameraOrientations? newOrientation;
            switch (data) {
              case "LANDSCAPE_LEFT":
                newOrientation = CameraOrientations.landscape_left;
              case "LANDSCAPE_RIGHT":
                newOrientation = CameraOrientations.landscape_right;
              case "PORTRAIT_UP":
                newOrientation = CameraOrientations.portrait_up;
              case "PORTRAIT_DOWN":
                newOrientation = CameraOrientations.portrait_down;
              default:
            }
            sink.add(newOrientation!);
          },
        ),
      );

  static Stream<CameraPhysicalButton>? listenPhysicalButton() {
    _physicalButtonStream ??= _physicalButtonChannel
        .receiveBroadcastStream("physicalButtonChannel")
        .transform(
      StreamTransformer<dynamic, CameraPhysicalButton>.fromHandlers(
        handleData: (data, EventSink<CameraPhysicalButton> sink) {
          CameraPhysicalButton? physicalButton;
          switch (data) {
            case "VOLUME_UP":
              physicalButton = CameraPhysicalButton.volume_up;
            case "VOLUME_DOWN":
              physicalButton = CameraPhysicalButton.volume_down;
            default:
          }
          sink.add(physicalButton!);
        },
      ),
    );
    return _physicalButtonStream;
  }

  static Stream<bool>? listenPermissionResult() {
    _permissionsStream ??= _permissionsChannel
        .receiveBroadcastStream("permissionsChannel")
        .transform(
      StreamTransformer<dynamic, bool>.fromHandlers(
        handleData: (data, EventSink<bool> sink) {
          sink.add(data);
        },
      ),
    );
    return _permissionsStream;
  }

  static Future<void> setupAnalysis({
    int width = 0,
    double? maxFramesPerSecond,
    required InputAnalysisImageFormat format,
    required bool autoStart,
  }) async =>
      CameraInterface().setupImageAnalysisStream(
        format.name,
        width,
        maxFramesPerSecond,
        autoStart,
      );

  static Stream<Map<String, dynamic>>? listenCameraImages() {
    _imagesStream ??=
        _imagesChannel.receiveBroadcastStream("imagesChannel").transform(
      StreamTransformer<dynamic, Map<String, dynamic>>.fromHandlers(
        handleData: (data, EventSink<Map<String, dynamic>> sink) {
          sink.add(Map<String, dynamic>.from(data));
        },
      ),
    );
    return _imagesStream;
  }

  static Future receivedImageFromStream() =>
      CameraInterface().receivedImageFromStream();

  static Future<bool?> init(
    SensorConfig sensorConfig,
    bool enableImageStream,
    bool enablePhysicalButton, {
    CaptureMode captureMode = CaptureMode.photo,
    required ExifPreferences exifPreferences,
    required VideoOptions? videoOptions,
    required bool mirrorFrontCamera,
  }) async =>
      CameraInterface()
          .setupCamera(
            sensorConfig.sensors.map((Sensor e) => e.toPigeon()).toList(),
            sensorConfig.aspectRatio.name.toUpperCase(),
            sensorConfig.zoom,
            mirrorFrontCamera,
            enablePhysicalButton,
            sensorConfig.flashMode.name.toUpperCase(),
            captureMode.name.toUpperCase(),
            enableImageStream,
            exifPreferences,
            videoOptions,
          )
          .then((bool value) => true);

  static Future<List<Size>> getSizes() async {
    final List<PreviewSize?> availableSizes =
        await CameraInterface().availableSizes();
    return availableSizes
        .whereType<PreviewSize>()
        .map((PreviewSize e) => Size(e.width, e.height))
        .toList();
  }

  static Future<num?> getPreviewTexture(final int cameraPosition) =>
      CameraInterface().getPreviewTextureId(cameraPosition);

  static Future<void> setPreviewSize(int width, int height) =>
      CameraInterface().setPreviewSize(
        PreviewSize(width: width.toDouble(), height: height.toDouble()),
      );

  static Future<void> refresh() => CameraInterface().refresh();

  /// android has a limits on preview size and fallback to 1920x1080 if preview is too big
  /// So to prevent having different ratio we get the real preview Size directly from nativ side
  static Future<PreviewSize> getEffectivPreviewSize(int index) async {
    final PreviewSize? ps =
        await CameraInterface().getEffectivPreviewSize(index);
    if (ps != null) {
      return PreviewSize(width: ps.width, height: ps.height);
    } else {
      // TODOShould not be null?
      return PreviewSize(width: 0, height: 0);
    }
  }

  /// you can set a different size for preview and for photo
  /// for iOS, when taking a photo, best quality is automatically used
  static Future<void> setPhotoSize(int width, int height) =>
      CameraInterface().setPhotoSize(
        PreviewSize(
          width: width.toDouble(),
          height: height.toDouble(),
        ),
      );

  static Future<bool> takePhoto(CaptureRequest captureRequest) async {
    final Map<PigeonSensor, String?> request = captureRequest.when(
      single: (SingleCaptureRequest single) => <PigeonSensor, String?>{
        single.sensor.toPigeon(): single.file?.path,
      },
      multiple: (MultipleCaptureRequest multiple) => multiple.fileBySensor.map(
          (Sensor key, XFile? value) => MapEntry(key.toPigeon(), value?.path)),
    );

    return CameraInterface().takePhoto(
      request.keys.toList(),
      request.values.toList(),
    );
  }

  static Future<void> recordVideo(CaptureRequest request) {
    final Map<PigeonSensor, String?> pathBySensor = request.when(
      single: (SingleCaptureRequest single) => <PigeonSensor, String?>{
        single.sensor.toPigeon(): single.file?.path,
      },
      multiple: (MultipleCaptureRequest multiple) => multiple.fileBySensor.map(
          (Sensor key, XFile? value) => MapEntry(key.toPigeon(), value?.path)),
    );
    if (Platform.isAndroid) {
      return CameraInterface().recordVideo(
        pathBySensor.keys.toList(),
        pathBySensor.values.toList(),
      );
    } else {
      return CameraInterface().recordVideo(
        pathBySensor.keys.toList(),
        pathBySensor.values.toList(),
      );
    }
  }

  static Future<void> pauseVideoRecording() async =>
      CameraInterface().pauseVideoRecording();

  static Future<void> resumeVideoRecording() =>
      CameraInterface().resumeVideoRecording();

  static Future<bool> stopRecordingVideo() =>
      CameraInterface().stopRecordingVideo();

  /// Switch flash mode from Android / iOS
  static Future<void> setFlashMode(FlashMode flashMode) =>
      CameraInterface().setFlashMode(flashMode.name.toUpperCase());

  static Future<void> startAutoFocus() => CameraInterface().handleAutoFocus();

  /// Start auto focus on a specific [position] with a given [previewSize].
  ///
  /// On Android, you can set [androidFocusSettings].
  /// It contains a parameter [AndroidFocusSettings.autoCancelDurationInMillis].
  /// It is the time in milliseconds after which the auto focus will be canceled.
  /// Passive focus will resume after that duration.
  ///
  /// If that duration is equals to or less than 0, auto focus is never
  /// cancelled and passive focus will not resume. After this, if you want to
  /// focus on an other point, you'll have to call again [focusOnPoint].
  static Future<void> focusOnPoint({
    required PreviewSize previewSize,
    required Offset position,
    required AndroidFocusSettings? androidFocusSettings,
  }) =>
      CameraInterface().focusOnPoint(
        previewSize,
        position.dx,
        position.dy,
        androidFocusSettings,
      );

  /// calls zoom from Android / iOS --
  static Future<void> setZoom(num zoom) =>
      CameraInterface().setZoom(zoom.toDouble());

  /// switch camera sensor between [Sensors.back] and [Sensors.front]
  /// on iOS, you can specify the deviceId if you have multiple cameras
  /// call [getSensors] to get the list of available cameras
  static Future<void> setSensor(List<Sensor?> sensors) =>
      CameraInterface().setSensor(
        sensors
            .map(
              (Sensor? e) => PigeonSensor(
                position: e?.position?.name != null
                    ? PigeonSensorPosition.values.byName(e!.position!.name)
                    : PigeonSensorPosition.unknown,
                deviceId: e?.deviceId,
                type: e?.type?.name != null
                    ? PigeonSensorType.values.byName(e!.type!.name)
                    : PigeonSensorType.unknown,
              ),
            )
            .toList(),
      );

  /// change capture mode between [CaptureMode.photo] and [CaptureMode.video]
  static Future<void> setCaptureMode(CaptureMode captureMode) =>
      CameraInterface().setCaptureMode(captureMode.name.toUpperCase());

  /// enable audio mode recording or not
  static Future<void> setAudioMode(bool enableAudio) =>
      CameraInterface().setRecordingAudioMode(enableAudio);

  /// set exif preferences when a photo is saved
  ///
  /// The GPS value can be null on Android if:
  /// - Location is disabled on the phone
  /// - ExifPreferences.saveGPSLocation is false
  /// - Permission ACCESS_FINE_LOCATION has not been granted
  static Future<bool> setExifPreferences(ExifPreferences savedExifData) =>
      CameraInterface().setExifPreferences(savedExifData);

  /// set brightness manually with range [0,1]
  static Future<void> setBrightness(double brightness) {
    if (brightness < 0 || brightness > 1) {
      throw "Value must be between [0,1]";
    }
    return CameraInterface().setCorrection(brightness);
  }

  /// returns the max zoom available on device
  static Future<double?> getMaxZoom() => CameraInterface().getMaxZoom();

  /// returns the min zoom available on device
  static Future<double?> getMinZoom() => CameraInterface().getMinZoom();

  static Future<bool> isMultiCamSupported() =>
      CameraInterface().isMultiCamSupported();

  /// Change aspect ratio when a photo is taken
  static Future<void> setAspectRatio(String ratio) =>
      CameraInterface().setAspectRatio(ratio.toUpperCase());

  // TODO: implement it on Android
  /// Returns the list of available sensors on device.
  ///
  /// The list contains the back and front sensors
  /// with their name, type, uid, iso and flash availability
  ///
  /// Only available on iOS for now
  static Future<SensorDeviceData> getSensors() async {
    if (Platform.isAndroid) {
      return Future.value(SensorDeviceData());
    } else {
      // Can't use getter with pigeon, so we have to map the data manually...
      final List<PigeonSensorTypeDevice?> frontSensors =
          await CameraInterface().getFrontSensors();
      final List<PigeonSensorTypeDevice?> backSensors =
          await CameraInterface().getBackSensors();

      final List<SensorTypeDevice> frontSensorsData = frontSensors
          .map(
            (PigeonSensorTypeDevice? data) => SensorTypeDevice(
              flashAvailable: data!.flashAvailable,
              iso: data.iso,
              name: data.name,
              uid: data.uid,
              sensorType: SensorType.values.firstWhere(
                (SensorType element) => element.name == data.sensorType.name,
              ),
            ),
          )
          .toList();
      final List<SensorTypeDevice> backSensorsData = backSensors
          .map(
            (PigeonSensorTypeDevice? data) => SensorTypeDevice(
              flashAvailable: data!.flashAvailable,
              iso: data.iso,
              name: data.name,
              uid: data.uid,
              sensorType: SensorType.values.firstWhere(
                (SensorType element) => element.name == data.sensorType.name,
              ),
            ),
          )
          .toList();

      return SensorDeviceData(
        ultraWideAngle: backSensorsData
            .where(
              (SensorTypeDevice element) =>
                  element.sensorType == SensorType.ultraWideAngle,
            )
            .toList()
            .firstOrNull,
        telephoto: backSensorsData
            .where(
              (SensorTypeDevice element) =>
                  element.sensorType == SensorType.telephoto,
            )
            .toList()
            .firstOrNull,
        wideAngle: backSensorsData
            .where(
              (SensorTypeDevice element) =>
                  element.sensorType == SensorType.wideAngle,
            )
            .toList()
            .firstOrNull,
        trueDepth: frontSensorsData
            .where(
              (SensorTypeDevice element) =>
                  element.sensorType == SensorType.trueDepth,
            )
            .toList()
            .firstOrNull,
      );
    }
  }

  // ---------------------------------------------------
  // UTILITY METHODS
  // ---------------------------------------------------
  static Future<List<CamerAwesomePermission>?> checkAndRequestPermissions(
    bool saveGpsLocation, {
    bool checkMicrophonePermissions = true,
    bool checkCameraPermissions = true,
  }) async {
    try {
      if (Platform.isAndroid) {
        return CameraInterface().requestPermissions(saveGpsLocation).then(
              (List<String?> givenPermissions) => givenPermissions
                  .map(
                    (String? e) => CamerAwesomePermission.values.firstWhere(
                        (CamerAwesomePermission element) => element.name == e),
                  )
                  .toList(),
            );
      } else if (Platform.isIOS) {
        // TODOiOS Return only permissions that were given

        final List<String> permissions = <String>[];
        if (checkMicrophonePermissions) {
          permissions.add("microphone");
        }
        if (checkCameraPermissions) {
          permissions.add("camera");
        }

        return CamerawesomePlugin.checkiOSPermissions(permissions)
            .then((bool? givenPermissions) => CamerAwesomePermission.values);
      }
    } on Exception catch (e) {
      printLog("failed to check permissions here...");
      // ignore: avoid_print
      print(e);
    }
    return Future.value(<CamerAwesomePermission>[]);
  }

  static Future<void> startAnalysis() => CameraInterface().startAnalysis();

  static Future<void> stopAnalysis() => CameraInterface().stopAnalysis();

  static Future<void> setFilter(AwesomeFilter filter) =>
      CameraInterface().setFilter(filter.matrix);

  static Future<void> setMirrorFrontCamera(bool mirrorFrontCamera) =>
      CameraInterface().setMirrorFrontCamera(mirrorFrontCamera);
}
