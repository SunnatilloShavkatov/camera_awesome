import "dart:io";

import "package:flutter/material.dart";

class AwesomeFocusIndicator extends StatelessWidget {

  const AwesomeFocusIndicator({super.key, required this.position});
  final Offset position;

  @override
  Widget build(BuildContext context) => IgnorePointer(
      child: TweenAnimationBuilder<double>(
        key: ValueKey(position),
        tween: Tween<double>(
          begin: 80,
          end: 50,
        ),
        duration: const Duration(milliseconds: 2000),
        curve: Curves.fastLinearToSlowEaseIn,
        builder: (_, double anim, Widget? child) => CustomPaint(
            painter: AwesomeFocusPainter(
              tapPosition: position,
              rectSize: anim,
            ),
          ),
      ),
    );
}

class AwesomeFocusPainter extends CustomPainter {

  AwesomeFocusPainter({required this.tapPosition, required this.rectSize});
  final double rectSize;
  final Offset tapPosition;

  @override
  void paint(Canvas canvas, Size size) {
    final bool isIOS = Platform.isIOS;

    final double baseX = tapPosition.dx - rectSize / 2;
    final double baseY = tapPosition.dy - rectSize / 2;

    final Path pathAndroid = Path()
      ..moveTo(baseX, baseY)
      ..lineTo(baseX + rectSize / 5, baseY)
      ..moveTo(baseX + 4 * rectSize / 5, baseY)
      ..lineTo(baseX + rectSize, baseY)
      ..lineTo(baseX + rectSize, baseY + rectSize / 5)
      ..moveTo(baseX + rectSize, baseY + 4 * rectSize / 5)
      ..lineTo(baseX + rectSize, baseY + rectSize)
      ..lineTo(baseX + 4 * rectSize / 5, baseY + rectSize)
      ..moveTo(baseX + rectSize / 5, baseY + rectSize)
      ..lineTo(baseX, baseY + rectSize)
      ..lineTo(baseX, baseY + 4 * rectSize / 5)
      ..moveTo(baseX, baseY + rectSize / 5)
      ..lineTo(baseX, baseY);

    final Path pathIOS = Path()
      ..moveTo(baseX, baseY)
      ..lineTo(baseX + rectSize / 2, baseY)
      ..lineTo(baseX + rectSize / 2, baseY + rectSize / 10)
      ..moveTo(baseX + rectSize / 2, baseY)
      ..lineTo(baseX + rectSize, baseY)
      ..lineTo(baseX + rectSize, baseY + rectSize / 2)
      ..lineTo(baseX + 9 / 10 * rectSize, baseY + rectSize / 2)
      ..moveTo(baseX + rectSize, baseY + rectSize / 2)
      ..lineTo(baseX + rectSize, baseY + rectSize)
      ..lineTo(baseX + rectSize / 2, baseY + rectSize)
      ..lineTo(baseX + rectSize / 2, baseY + 9 / 10 * rectSize)
      ..moveTo(baseX + rectSize / 2, baseY + rectSize)
      ..lineTo(baseX, baseY + rectSize)
      ..lineTo(baseX, baseY + rectSize / 2)
      ..lineTo(baseX + 1 / 10 * rectSize, baseY + rectSize / 2)
      ..moveTo(baseX, baseY + rectSize / 2)
      ..lineTo(baseX, baseY);

    canvas.drawPath(
      isIOS ? pathIOS : pathAndroid,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant AwesomeFocusPainter oldDelegate) => rectSize != oldDelegate.rectSize ||
        tapPosition != oldDelegate.tapPosition;
}
