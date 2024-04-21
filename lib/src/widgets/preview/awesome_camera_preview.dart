// ignore_for_file: discarded_futures

import "dart:async";
import "dart:io";

import "package:camera_awesome/camerawesome_plugin.dart";
import "package:camera_awesome/pigeon.dart";
import "package:camera_awesome/src/widgets/preview/awesome_preview_fit.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

enum CameraPreviewFit {
  fitWidth,
  fitHeight,
  contain,
  cover,
}

/// This is a fullscreen camera preview
/// some part of the preview are cropped so we have a full sized camera preview
class AwesomeCameraPreview extends StatefulWidget {
  const AwesomeCameraPreview({
    super.key,
    this.loadingWidget,
    required this.state,
    this.onPreviewTap,
    this.onPreviewScale,
    this.previewFit = CameraPreviewFit.cover,
    required this.interfaceBuilder,
    this.previewDecoratorBuilder,
    required this.padding,
    required this.alignment,
    this.pictureInPictureConfigBuilder,
  });

  final CameraPreviewFit previewFit;
  final Widget? loadingWidget;
  final CameraState state;
  final OnPreviewTap? onPreviewTap;
  final OnPreviewScale? onPreviewScale;
  final CameraLayoutBuilder interfaceBuilder;
  final CameraLayoutBuilder? previewDecoratorBuilder;
  final EdgeInsets padding;
  final Alignment alignment;
  final PictureInPictureConfigBuilder? pictureInPictureConfigBuilder;

  @override
  State<StatefulWidget> createState() => AwesomeCameraPreviewState();
}

class AwesomeCameraPreviewState extends State<AwesomeCameraPreview> {
  PreviewSize? _previewSize;

  final List<Texture> _textures = <Texture>[];

  PreviewSize? get pixelPreviewSize => _previewSize;

  StreamSubscription? _sensorConfigSubscription;
  StreamSubscription? _aspectRatioSubscription;
  CameraAspectRatios? _aspectRatio;
  double? _aspectRatioValue;
  Preview? _preview;

  // TODO: fetch this value from the native side
  final int kMaximumSupportedFloatingPreview = 3;

  @override
  void initState() {
    super.initState();
    Future.wait(<Future>[
      widget.state.previewSize(0),
    ]).then((List data) {
      if (mounted) {
        setState(() {
          _previewSize = data[0];
        });
      }
    });

    // refactor this
    _sensorConfigSubscription =
        widget.state.sensorConfig$.listen((SensorConfig sensorConfig) {
      _aspectRatioSubscription?.cancel();
      _aspectRatioSubscription =
          sensorConfig.aspectRatio$.listen((CameraAspectRatios event) async {
        final PreviewSize previewSize = await widget.state.previewSize(0);
        if ((_previewSize != previewSize || _aspectRatio != event) && mounted) {
          setState(() {
            _aspectRatio = event;
            switch (event) {
              case CameraAspectRatios.ratio_16_9:
                _aspectRatioValue = 16 / 9;
              case CameraAspectRatios.ratio_4_3:
                _aspectRatioValue = 4 / 3;
              case CameraAspectRatios.ratio_1_1:
                _aspectRatioValue = 1;
            }
            _previewSize = previewSize;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _sensorConfigSubscription?.cancel();
    _aspectRatioSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_textures.isEmpty || _previewSize == null || _aspectRatio == null) {
      return widget.loadingWidget ??
          Center(
            child: Platform.isIOS
                ? const CupertinoActivityIndicator()
                : const CircularProgressIndicator(),
          );
    }

    return ColoredBox(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => Stack(
          children: <Widget>[
            Positioned.fill(
              child: AnimatedPreviewFit(
                alignment: widget.alignment,
                previewFit: widget.previewFit,
                previewSize: _previewSize!,
                constraints: constraints,
                sensor: widget.state.sensorConfig.sensors.first,
                onPreviewCalculated: (Preview preview) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((Duration timeStamp) {
                    if (mounted) {
                      setState(() {
                        _preview = preview;
                      });
                    }
                  });
                },
                child: AwesomeCameraGestureDetector(
                  onPreviewTapBuilder:
                      widget.onPreviewTap != null && _previewSize != null
                          ? OnPreviewTapBuilder(
                              pixelPreviewSizeGetter: () => _previewSize!,
                              flutterPreviewSizeGetter: () =>
                                  _previewSize!, //croppedPreviewSize,
                              onPreviewTap: widget.onPreviewTap!,
                            )
                          : null,
                  onPreviewScale: widget.onPreviewScale,
                  initialZoom: widget.state.sensorConfig.zoom,
                  child: StreamBuilder<AwesomeFilter>(
                    //FIX performances
                    stream: widget.state.filter$,
                    builder: (BuildContext context,
                            AsyncSnapshot<AwesomeFilter> snapshot) =>
                        snapshot.hasData && snapshot.data != AwesomeFilter.None
                            ? ColorFiltered(
                                colorFilter: snapshot.data!.preview,
                                child: _textures.first,
                              )
                            : _textures.first,
                  ),
                ),
              ),
            ),
            if (widget.previewDecoratorBuilder != null && _preview != null)
              Positioned.fill(
                child: widget.previewDecoratorBuilder!(
                  widget.state,
                  _preview!,
                ),
              ),
            if (_preview != null)
              Positioned.fill(
                child: widget.interfaceBuilder(
                  widget.state,
                  _preview!,
                ),
              ),
            // TODO: be draggable
            // TODO: add shadow & border
            ..._buildPreviewTextures(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPreviewTextures() {
    final List<Widget> previewFrames = <Widget>[];
    // if there is only one texture
    if (_textures.length <= 1) {
      return previewFrames;
    }
    // ignore: invalid_use_of_protected_member
    final List<Sensor> sensors =
        widget.state.cameraContext.sensorConfig.sensors;

    for (int i = 1; i < _textures.length; i++) {
      // TODO: add a way to retrive how camera can be added ("budget" on iOS ?)
      if (i >= kMaximumSupportedFloatingPreview) {
        break;
      }

      final Texture texture = _textures[i];
      final Sensor sensor = sensors[kDebugMode ? 0 : i];
      final AwesomeCameraFloatingPreview frame = AwesomeCameraFloatingPreview(
        index: i,
        sensor: sensor,
        texture: texture,
        aspectRatio: 1 / _aspectRatioValue!,
        pictureInPictureConfig:
            widget.pictureInPictureConfigBuilder?.call(i, sensor) ??
                PictureInPictureConfig(
                  startingPosition: Offset(
                    i * 20,
                    MediaQuery.of(context).padding.top + 60 + (i * 20),
                  ),
                  sensor: sensor,
                ),
      );
      previewFrames.add(frame);
    }

    return previewFrames;
  }
}
