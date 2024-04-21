import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";

class AwesomeOrientedWidget extends StatefulWidget {

  const AwesomeOrientedWidget({
    super.key,
    required this.child,
    this.rotateWithDevice = true,
  });
  final Widget child;
  final bool rotateWithDevice;

  @override
  State<StatefulWidget> createState() => AwesomeOrientedWidgetState();
}

class AwesomeOrientedWidgetState extends State<AwesomeOrientedWidget> {
  CameraOrientations previousOrientation = CameraOrientations.portrait_up;
  double turns = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.rotateWithDevice) {
      return StreamBuilder<CameraOrientations>(
        stream: CamerawesomePlugin.getNativeOrientation(),
        builder: (_, AsyncSnapshot<CameraOrientations> orientationSnapshot) {
          final CameraOrientations? orientation = orientationSnapshot.data;
          if (orientation != null && orientation != previousOrientation) {
            turns = shortestTurnsToReachTarget(
              current: turns,
              target: getTurns(orientation),
            );
            previousOrientation = orientation;
          }

          return AnimatedRotation(
            turns: turns,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: widget.child,
          );
        },
      );
    } else {
      return widget.child;
    }
  }

  double getTurns(CameraOrientations orientation) {
    switch (orientation) {
      case CameraOrientations.landscape_left:
        return 0.75;
      case CameraOrientations.landscape_right:
        return 0.25;
      case CameraOrientations.portrait_up:
        return 0;
      case CameraOrientations.portrait_down:
        return 0.5;
    }
  }

  /// Determines which next turn value should be used to have the least rotation
  /// movements between [current] and [target]
  ///
  /// E.g: when being at 0.5 turns, should I go to 0.75 or to -0.25 to minimize
  /// the rotation ?
  double shortestTurnsToReachTarget(
      {required double current, required double target,}) {
    final double currentDegree = current * 360;
    final double targetDegree = target * 360;

    // Determine if we need to go clockwise or counterclockwise to reach
    // the next angle with the least movements
    // See https://math.stackexchange.com/a/2898118
    final bool clockWise = (targetDegree - currentDegree + 540) % 360 - 180 > 0;
    double resultDegree = currentDegree;
    do {
      resultDegree += (clockWise ? 1 : -1) * 360 / 4;
    } while (resultDegree % 360 != targetDegree % 360);

    // Revert back to turns
    return resultDegree / 360;
  }
}
