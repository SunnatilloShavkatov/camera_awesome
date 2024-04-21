// ignore_for_file: library_private_types_in_public_api

import "package:camera_awesome/src/orchestrator/analysis/analysis_controller.dart";
import "package:camera_awesome/src/orchestrator/states/camera_state.dart";
import "package:camera_awesome/src/orchestrator/states/photo_camera_state.dart";
import "package:camera_awesome/src/orchestrator/states/video_camera_recording_state.dart";
import "package:camera_awesome/src/orchestrator/states/video_camera_state.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class AwesomeCaptureButton extends StatefulWidget {

  const AwesomeCaptureButton({
    super.key,
    required this.state,
  });
  final CameraState state;

  @override
  _AwesomeCaptureButtonState createState() => _AwesomeCaptureButtonState();
}

class _AwesomeCaptureButtonState extends State<AwesomeCaptureButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late double _scale;
  final Duration _duration = const Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state is AnalysisController) {
      return Container();
    }
    _scale = 1 - _animationController.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        key: const ValueKey("cameraButton"),
        height: 80,
        width: 80,
        child: Transform.scale(
          scale: _scale,
          child: CustomPaint(
            painter: widget.state.when(
              onPhotoMode: (_) => CameraButtonPainter(),
              onPreparingCamera: (_) => CameraButtonPainter(),
              onVideoMode: (_) => VideoButtonPainter(),
              onVideoRecordingMode: (_) =>
                  VideoButtonPainter(isRecording: true),
            ),
          ),
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    HapticFeedback.selectionClick();
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    Future.delayed(_duration, () {
      _animationController.reverse();
    });

    onTap.call();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  Null Function() get onTap => () {
        widget.state.when(
          onPhotoMode: (PhotoCameraState photoState) => photoState.takePhoto(),
          onVideoMode: (VideoCameraState videoState) => videoState.startRecording(),
          onVideoRecordingMode: (VideoRecordingCameraState videoState) => videoState.stopRecording(),
        );
      };
}

class CameraButtonPainter extends CustomPainter {
  CameraButtonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPainter = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    bgPainter.color = Colors.white.withOpacity(.5);
    canvas.drawCircle(center, radius, bgPainter);

    bgPainter.color = Colors.white;
    canvas.drawCircle(center, radius - 8, bgPainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class VideoButtonPainter extends CustomPainter {

  VideoButtonPainter({
    this.isRecording = false,
  });
  final bool isRecording;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPainter = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    bgPainter.color = Colors.white.withOpacity(.5);
    canvas.drawCircle(center, radius, bgPainter);

    if (isRecording) {
      bgPainter.color = Colors.red;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(
                17,
                17,
                size.width - (17 * 2),
                size.height - (17 * 2),
              ),
              const Radius.circular(12),),
          bgPainter,);
    } else {
      bgPainter.color = Colors.red;
      canvas.drawCircle(center, radius - 8, bgPainter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
