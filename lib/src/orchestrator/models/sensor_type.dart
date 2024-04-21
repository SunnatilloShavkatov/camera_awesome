// ignore_for_file: flutter_style_todos
enum SensorType {
  /// A built-in wide-angle camera.
  ///
  /// The wide angle sensor is the default sensor for iOS
  wideAngle,

  /// A built-in camera with a shorter focal length than that of the wide-angle camera.
  ultraWideAngle,

  /// A built-in camera device with a longer focal length than the wide-angle camera.
  telephoto,

  /// A device that consists of two cameras, one Infrared and one YUV.
  ///
  /// iOS only
  trueDepth,

  unknown;

  SensorType get defaultSensorType => SensorType.wideAngle;
}

class SensorTypeDevice {

  SensorTypeDevice({
    required this.sensorType,
    required this.name,
    required this.iso,
    required this.flashAvailable,
    required this.uid,
  });
  final SensorType sensorType;

  /// A localized device name for display in the user interface.
  final String name;

  /// The current exposure ISO value.
  final num iso;

  /// A Boolean value that indicates whether the flash is currently available for use.
  final bool flashAvailable;

  /// An identifier that uniquely identifies the device.
  final String uid;
}

// TODO: instead of storing SensorTypeDevice values,
// this would be useful when CameraX will support multiple sensors.
// store them in a list of SensorTypeDevice.
// ex:
// List<SensorTypeDevice> wideAngle;
// List<SensorTypeDevice> ultraWideAngle;

class SensorDeviceData {

  SensorDeviceData({
    this.wideAngle,
    this.ultraWideAngle,
    this.telephoto,
    this.trueDepth,
  });
  /// A built-in wide-angle camera.
  ///
  /// The wide angle sensor is the default sensor for iOS
  SensorTypeDevice? wideAngle;

  /// A built-in camera with a shorter focal length than that of the wide-angle camera.
  SensorTypeDevice? ultraWideAngle;

  /// A built-in camera device with a longer focal length than the wide-angle camera.
  SensorTypeDevice? telephoto;

  /// A device that consists of two cameras, one Infrared and one YUV.
  ///
  /// iOS only
  SensorTypeDevice? trueDepth;

  List<SensorTypeDevice> get availableSensors => <SensorTypeDevice?>[
      wideAngle,
      ultraWideAngle,
      telephoto,
      trueDepth,
    ].where((SensorTypeDevice? element) => element != null).cast<SensorTypeDevice>().toList();

  int get availableBackSensors => <SensorTypeDevice?>[
        wideAngle,
        ultraWideAngle,
        telephoto,
      ].where((SensorTypeDevice? element) => element != null).length;

  int get availableFrontSensors => <SensorTypeDevice?>[
        trueDepth,
      ].where((SensorTypeDevice? element) => element != null).length;
}
