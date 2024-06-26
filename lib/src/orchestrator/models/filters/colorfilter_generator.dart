library colorfilter_generator;

import 'package:flutter/material.dart';
import 'package:matrix2d/matrix2d.dart';

/// The [ColorFilterGenerator] class to define a Filter which will applied to each color, consists of multiple [SubFilter]s
class ColorFilterGenerator {
  String name;
  List<List<double>> filters;
  List<double> matrix = [
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0
  ];

  ColorFilterGenerator({
    required this.name,
    required this.filters,
  }) {
    buildMatrix();
  }

  // | a00 a01 a02 a03 a04 |   | a00 a01 a02 a03 a04 |
  // | a10 a11 a22 a33 a44 |   | a10 a11 a22 a33 a44 |
  // | a20 a21 a22 a33 a44 | * | a20 a21 a22 a33 a44 |
  // | a30 a31 a22 a33 a44 |   | a30 a31 a22 a33 a44 |
  // |  0   0   0   0   1  |   |  0   0   0   0   1  |
  /// Build matrix of current filter
  void buildMatrix() {
    if (filters.isEmpty) {
      return;
    }

    Matrix2d m2d = const Matrix2d();

    List result = m2d.reshape([filters[0]], 4, 5);
    // List listA = m2d.reshape([filters[0]], 4, 5);

    for (int i = 1; i < filters.length; i++) {
      List listB = [
        ...(filters[i] is ColorFilterGenerator
            ? (filters[i] as ColorFilterGenerator).matrix
            : filters[i]),
        0,
        0,
        0,
        0,
        1,
      ];

      // print(listA);
      // print(listB);

      result = m2d.dot(
        result,
        m2d.reshape([listB], 5, 5),
      );
    }

    matrix = List<double>.from(result.flatten.sublist(0, 20));
  }

  /// Create new filter from this filter with given opacity
  ColorFilterGenerator opacity(double value) {
    return ColorFilterGenerator(name: name, filters: [
      ...filters,
      [
        value,
        0,
        0,
        0,
        0,
        0,
        value,
        0,
        0,
        0,
        0,
        0,
        value,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ],
    ]);
  }

  /// Apply filter to given child
  Widget build(Widget child) {
    Widget tree = child;

    for (int i = 0; i < filters.length; i++) {
      tree = ColorFiltered(
        colorFilter: ColorFilter.matrix(filters[i]),
        child: tree,
      );
    }

    return tree;
  }
}