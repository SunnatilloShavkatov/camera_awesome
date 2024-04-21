import "dart:math";

import "package:flutter/material.dart";

class CanvasTransformation {

  const CanvasTransformation({
    this.scale,
    this.translate,
  });
  final Point? scale;
  final Point? translate;
}

extension CanvasTransformationExt on Canvas {
  void applyTransformation(
    CanvasTransformation transformation,
    Size canvasSize,
  ) {
    if (transformation.scale != null) {
      scale(transformation.scale!.x.toDouble(),
          transformation.scale!.y.toDouble(),);
    }
    if (transformation.translate != null) {
      translate(
        transformation.translate!.x.toDouble() * canvasSize.width,
        transformation.translate!.y.toDouble() * canvasSize.height,
      );
    }
  }
}

extension PointExt on Point {
  Offset toOffset() => Offset(x.toDouble(), y.toDouble());
}
