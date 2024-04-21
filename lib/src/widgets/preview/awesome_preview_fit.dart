import "dart:math";

import "package:camera_awesome/camerawesome_plugin.dart";
import "package:camera_awesome/pigeon.dart";
import "package:flutter/material.dart";

final GlobalKey<State<StatefulWidget>> previewWidgetKey = GlobalKey();

typedef OnPreviewCalculated = void Function(Preview preview);

class AnimatedPreviewFit extends StatefulWidget {
  const AnimatedPreviewFit({
    super.key,
    this.alignment = Alignment.center,
    required this.previewFit,
    required this.previewSize,
    required this.constraints,
    required this.sensor,
    required this.child,
    this.onPreviewCalculated,
  });

  final Alignment alignment;
  final CameraPreviewFit previewFit;
  final PreviewSize previewSize;
  final BoxConstraints constraints;
  final Widget child;
  final OnPreviewCalculated? onPreviewCalculated;
  final Sensor sensor;

  @override
  State<AnimatedPreviewFit> createState() => _AnimatedPreviewFitState();
}

class _AnimatedPreviewFitState extends State<AnimatedPreviewFit> {
  late Tween<Size> animation;
  Size? maxSize;

  PreviewSizeCalculator? sizeCalculator;

  @override
  void initState() {
    super.initState();
    sizeCalculator = PreviewSizeCalculator(
      previewFit: widget.previewFit,
      previewSize: widget.previewSize,
      constraints: widget.constraints,
    );
    sizeCalculator!.compute();
    maxSize = sizeCalculator!.maxSize;

    animation = Tween<Size>(
      begin: maxSize,
      end: maxSize,
    );
    _handPreviewCalculated();
  }

  @override
  void didUpdateWidget(covariant AnimatedPreviewFit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.previewFit != oldWidget.previewFit ||
        widget.previewSize != oldWidget.previewSize ||
        widget.constraints != oldWidget.constraints) {
      final PreviewSizeCalculator oldsizeCalculator = PreviewSizeCalculator(
        previewFit: oldWidget.previewFit,
        previewSize: oldWidget.previewSize,
        constraints: oldWidget.constraints,
      );
      sizeCalculator = PreviewSizeCalculator(
        previewFit: widget.previewFit,
        previewSize: widget.previewSize,
        constraints: widget.constraints,
      );
      oldsizeCalculator.compute();
      sizeCalculator!.compute();
      animation = Tween<Size>(
        begin: oldsizeCalculator.maxSize,
        end: sizeCalculator!.maxSize,
      );
      _handPreviewCalculated();
    }
  }

  void _handPreviewCalculated() {
    if (widget.onPreviewCalculated != null) {
      widget.onPreviewCalculated!(
        Preview(
          nativePreviewSize: widget.previewSize.toSize(),
          previewSize: sizeCalculator!.maxSize,
          offset: sizeCalculator!.offset,
          scale: sizeCalculator!.zoom,
          sensor: widget.sensor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    // final RenderBox renderBox =
    //     previewWidgetKey.currentContext?.findRenderObject() as RenderBox;
    // final position = renderBox.localToGlobal(Offset.zero);
    // this contains the translations from the top left corner of the screen
    // debugPrint(
    //     "==> position ${position.dx}, ${position.dy} | ${renderBox.size}");
    // });

    return TweenAnimationBuilder<Size>(
      builder: (BuildContext context, Size currentSize, Widget? child) {
        final double ratio = sizeCalculator!.zoom;
        return PreviewFitWidget(
          alignment: widget.alignment,
          constraints: widget.constraints,
          previewFit: widget.previewFit,
          previewSize: widget.previewSize,
          scale: ratio,
          maxSize: maxSize!,
          child: child!,
        );
      },
      tween: animation,
      duration: const Duration(milliseconds: 700),
      curve: Curves.fastLinearToSlowEaseIn,
      child: widget.child,
    );
  }
}

class PreviewFitWidget extends StatelessWidget {
  const PreviewFitWidget({
    super.key,
    required this.alignment,
    required this.constraints,
    required this.previewFit,
    required this.previewSize,
    required this.child,
    required this.scale,
    required this.maxSize,
  });

  final Alignment alignment;
  final BoxConstraints constraints;
  final CameraPreviewFit previewFit;
  final PreviewSize previewSize;
  final Widget child;
  final double scale;
  final Size maxSize;

  @override
  Widget build(BuildContext context) {
    final TransformationController transformController =
        TransformationController()..value = (Matrix4.identity()..scale(scale));
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: maxSize.width,
        height: maxSize.height,
        child: InteractiveViewer(
          // key: previewWidgetKey,
          transformationController: transformController,
          scaleEnabled: false,
          constrained: false,
          panEnabled: false,
          alignment: FractionalOffset.topLeft,
          clipBehavior: Clip.antiAlias,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: previewSize.width,
              height: previewSize.height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  double get previewRatio => previewSize.width / previewSize.height;
}

@immutable
class PreviewSizeCalculator {
  PreviewSizeCalculator({
    required this.previewFit,
    required this.previewSize,
    required this.constraints,
  });

  final CameraPreviewFit previewFit;
  final PreviewSize previewSize;
  final BoxConstraints constraints;

  Size? _maxSize;
  double? _zoom;
  Offset? _offset;

  void compute() {
    _zoom ??= _computeZoom();
    _maxSize ??= _computeMaxSize();
  }

  double get zoom {
    if (_zoom == null) {
      throw Exception("Call compute() before");
    }
    return _zoom!;
  }

  Size get maxSize {
    if (_maxSize == null) {
      throw Exception("Call compute() before");
    }
    return _maxSize!;
  }

  Offset get offset {
    if (_offset == null) {
      throw Exception("Call compute() before");
    }
    return _offset!;
  }

  Size _computeMaxSize() {
    final Size nativePreviewSize = previewSize.toSize();
    Size maxSize;
    final double nativeWidthProjection = constraints.maxWidth * 1 / zoom;
    final double wDiff = nativePreviewSize.width - nativeWidthProjection;

    final double nativeHeightProjection = constraints.maxHeight * 1 / zoom;
    final double hDiff = nativePreviewSize.height - nativeHeightProjection;

    switch (previewFit) {
      case CameraPreviewFit.fitWidth:
        maxSize = Size(constraints.maxWidth, nativePreviewSize.height * zoom);
        _offset = Offset(0, constraints.maxHeight - maxSize.height);
      case CameraPreviewFit.fitHeight:
        maxSize = Size(nativePreviewSize.width * zoom, constraints.maxHeight);
        _offset = Offset(constraints.maxWidth - maxSize.width, 0);
      case CameraPreviewFit.cover:
        maxSize = Size(constraints.maxWidth, constraints.maxHeight);

        if (constraints.maxWidth / constraints.maxHeight >
            previewSize.width / previewSize.height) {
          _offset = Offset((hDiff * zoom) * 2, 0);
          // _offset = Offset(0, constraints.maxHeight - maxSize.height);
        } else {
          _offset = Offset(0, wDiff * zoom);
          // _offset = Offset(constraints.maxWidth - maxSize.width, 0);
        }
      case CameraPreviewFit.contain:
        maxSize = Size(
          nativePreviewSize.width * zoom,
          nativePreviewSize.height * zoom,
        );
        _offset = Offset(
          constraints.maxWidth - maxSize.width,
          constraints.maxHeight - maxSize.height,
        );
    }

    return maxSize;
  }

  PreviewSize getMaxPreviewSize() => PreviewSize(
        width: maxSize.width,
        height: maxSize.height,
      );

  double _computeZoom() {
    late double ratio;
    final Size nativePreviewSize = previewSize.toSize();

    switch (previewFit) {
      case CameraPreviewFit.fitWidth:
        ratio = constraints.maxWidth / nativePreviewSize.width; // 800 / 960
      case CameraPreviewFit.fitHeight:
        ratio = constraints.maxHeight / nativePreviewSize.height; // 1220 / 1280
      case CameraPreviewFit.cover:
        if (constraints.maxWidth / constraints.maxHeight >
            nativePreviewSize.width / nativePreviewSize.height) {
          ratio = constraints.maxWidth / nativePreviewSize.width;
        } else {
          ratio = constraints.maxHeight / nativePreviewSize.height;
        }
      case CameraPreviewFit.contain:
        final double ratioW = constraints.maxWidth / nativePreviewSize.width;
        final double ratioH = constraints.maxHeight / nativePreviewSize.height;
        final double minRatio = min(ratioW, ratioH);
        ratio = minRatio;
    }
    return ratio;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreviewSizeCalculator &&
          runtimeType == other.runtimeType &&
          previewFit == other.previewFit &&
          constraints == other.constraints &&
          previewSize == other.previewSize;

  @override
  int get hashCode => previewSize.hashCode ^ previewSize.hashCode;
}
