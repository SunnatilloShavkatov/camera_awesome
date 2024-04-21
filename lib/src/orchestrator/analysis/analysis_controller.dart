// ignore_for_file: unawaited_futures

import "dart:async";
import "dart:io";

import "package:camera_awesome/camerawesome_plugin.dart";
import "package:camera_awesome/src/logger.dart";

class AnalysisController {

  AnalysisController._({
    required Stream<Map<String, dynamic>>? images$,
    required this.conf,
    this.onImageListener,
    required bool analysisEnabled,
  })  : _images$ = images$,
        _analysisEnabled = analysisEnabled;

  factory AnalysisController.fromPlugin({
    OnImageForAnalysis? onImageListener,
    required AnalysisConfig? conf,
  }) =>
      AnalysisController._(
        onImageListener: onImageListener,
        conf: conf ?? AnalysisConfig(),
        images$: CamerawesomePlugin.listenCameraImages(),
        analysisEnabled: conf?.autoStart ?? true,
      );
  final OnImageForAnalysis? onImageListener;

  final Stream<Map<String, dynamic>>? _images$;

  final AnalysisConfig conf;

  StreamSubscription? imageSubscription;

  bool _analysisEnabled;

  Future<void> setup() async {
    if (onImageListener == null) {
      printLog("...AnalysisController off, no onImageListener");
      return;
    }
    if (imageSubscription != null) {
      printLog("AnalysisController controller already started");
      return;
    }

    if (Platform.isIOS) {
      await CamerawesomePlugin.setupAnalysis(
        format: conf.cupertinoOptions.outputFormat,
        maxFramesPerSecond: conf.maxFramesPerSecond,
        autoStart: conf.autoStart,
      );
    } else {
      await CamerawesomePlugin.setupAnalysis(
        format: conf.androidOptions.outputFormat,
        width: conf.androidOptions.width,
        maxFramesPerSecond: conf.maxFramesPerSecond,
        autoStart: conf.autoStart,
      );
    }

    if (conf.autoStart) {
      await start();
    }
    printLog("...AnalysisController setup");
  }

  bool get enabled => onImageListener != null && _analysisEnabled;

  // this should not return a bool but just throw an exception if something goes wrong
  Future<bool> start() async {
    if (onImageListener == null || imageSubscription != null) {
      return false;
    }
    await CamerawesomePlugin.startAnalysis();
    imageSubscription = _images$?.listen((Map<String, dynamic> event) async {
      await onImageListener!(AnalysisImage.from(event));
      await CamerawesomePlugin.receivedImageFromStream();
    });
    _analysisEnabled = true;
    printLog("...AnalysisController started");
    return _analysisEnabled;
  }

  Future<void> stop() async {
    if (onImageListener == null || imageSubscription == null) {
      return;
    }
    _analysisEnabled = false;
    await CamerawesomePlugin.stopAnalysis();
    imageSubscription?.cancel();
    imageSubscription = null;
  }
}
