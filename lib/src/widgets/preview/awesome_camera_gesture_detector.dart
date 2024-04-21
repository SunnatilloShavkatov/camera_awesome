import "dart:async";

import "package:camera_awesome/pigeon.dart";
import "package:camera_awesome/src/widgets/preview/awesome_focus_indicator.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";

Widget _awesomeFocusBuilder(Offset tapPosition) => AwesomeFocusIndicator(position: tapPosition);

class OnPreviewTapBuilder {

  const OnPreviewTapBuilder({
    required this.pixelPreviewSizeGetter,
    required this.flutterPreviewSizeGetter,
    required this.onPreviewTap,
  });
  // Use getters instead of storing the direct value to retrieve the data onTap
  final PreviewSize Function() pixelPreviewSizeGetter;
  final PreviewSize Function() flutterPreviewSizeGetter;
  final OnPreviewTap onPreviewTap;
}

class OnPreviewTap {

  const OnPreviewTap({
    required this.onTap,
    this.onTapPainter = _awesomeFocusBuilder,
    this.tapPainterDuration = const Duration(milliseconds: 2000),
  });
  final Function(Offset position, PreviewSize flutterPreviewSize,
      PreviewSize pixelPreviewSize,) onTap;
  final Widget Function(Offset tapPosition)? onTapPainter;
  final Duration? tapPainterDuration;
}

class OnPreviewScale {

  const OnPreviewScale({
    required this.onScale,
  });
  final Function(double scale) onScale;
}

class AwesomeCameraGestureDetector extends StatefulWidget {

  const AwesomeCameraGestureDetector({
    super.key,
    required this.child,
    required this.onPreviewScale,
    this.onPreviewTapBuilder,
    this.initialZoom = 0,
  });
  final Widget child;
  final OnPreviewTapBuilder? onPreviewTapBuilder;
  final OnPreviewScale? onPreviewScale;
  final double initialZoom;

  @override
  State<StatefulWidget> createState() => _AwesomeCameraGestureDetector();
}

class _AwesomeCameraGestureDetector
    extends State<AwesomeCameraGestureDetector> {
  double _zoomScale = 0;
  final double _accuracy = 0.01;
  double? _lastScale;

  Offset? _tapPosition;
  Timer? _timer;

  @override
  void initState() {
    _zoomScale = widget.initialZoom;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        if (widget.onPreviewScale != null)
          ScaleGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            () => ScaleGestureRecognizer()
              ..onStart = (_) {
                _lastScale = null;
              }
              ..onUpdate = (ScaleUpdateDetails details) {
                _lastScale ??= details.scale;
                if (details.scale < (_lastScale! + 0.01) &&
                    details.scale > (_lastScale! - 0.01)) {
                  return;
                } else if (_lastScale! < details.scale) {
                  _zoomScale += _accuracy;
                } else {
                  _zoomScale -= _accuracy;
                }

                _zoomScale = _zoomScale.clamp(0, 1);
                widget.onPreviewScale!.onScale(_zoomScale);
                _lastScale = details.scale;
              },
            (ScaleGestureRecognizer instance) {},
          ),
        if (widget.onPreviewTapBuilder != null)
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            () => TapGestureRecognizer()
              ..onTapUp = (TapUpDetails details) {
                if (widget
                        .onPreviewTapBuilder!.onPreviewTap.tapPainterDuration !=
                    null) {
                  _timer?.cancel();
                  _timer = Timer(
                      widget.onPreviewTapBuilder!.onPreviewTap
                          .tapPainterDuration!, () {
                    setState(() {
                      _tapPosition = null;
                    });
                  });
                }
                setState(() {
                  _tapPosition = details.localPosition;
                });
                widget.onPreviewTapBuilder!.onPreviewTap.onTap(
                  _tapPosition!,
                  widget.onPreviewTapBuilder!.flutterPreviewSizeGetter(),
                  widget.onPreviewTapBuilder!.pixelPreviewSizeGetter(),
                );
              },
            (TapGestureRecognizer instance) {},
          ),
      },
      child: Stack(children: <Widget>[
        Positioned.fill(child: widget.child),
        if (_tapPosition != null &&
            widget.onPreviewTapBuilder?.onPreviewTap.onTapPainter != null)
          widget.onPreviewTapBuilder!.onPreviewTap.onTapPainter!(_tapPosition!),
      ],),
    );

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
