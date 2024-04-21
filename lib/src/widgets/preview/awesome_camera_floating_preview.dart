import "package:camera_awesome/pigeon.dart";
import "package:camera_awesome/src/orchestrator/models/sensors.dart";
import "package:camera_awesome/src/widgets/preview/awesome_preview_fit.dart";
import "package:camera_awesome/src/widgets/widgets.dart";
import "package:flutter/material.dart";

class AwesomeCameraFloatingPreview extends StatefulWidget {

  AwesomeCameraFloatingPreview({
    super.key,
    required this.index,
    required this.sensor,
    required this.texture,
    required this.aspectRatio,
    PictureInPictureConfig? pictureInPictureConfig,
  }) : pictureInPictureConfig =
            pictureInPictureConfig ?? PictureInPictureConfig(sensor: sensor);
  final Texture texture;
  final int index;
  final double aspectRatio;
  final Sensor sensor;
  final PictureInPictureConfig pictureInPictureConfig;

  @override
  State<AwesomeCameraFloatingPreview> createState() =>
      _AwesomeCameraFloatingPreviewState();
}

class _AwesomeCameraFloatingPreviewState
    extends State<AwesomeCameraFloatingPreview> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.pictureInPictureConfig.startingPosition;
  }

  @override
  Widget build(BuildContext context) => Positioned(
      left: _position.dx,
      top: _position.dy,
      child: AwesomeBouncingWidget(
        // TODOWe can tap behind the preview with the current AwesomeBouncingWidget implementation
        onTap: widget.pictureInPictureConfig.onTap,
        disabledOpacity: 1,
        child: GestureDetector(
          onPanUpdate: widget.pictureInPictureConfig.isDraggable
              ? (DragUpdateDetails details) {
                  setState(() {
                    _position = Offset(
                      _position.dx + details.delta.dx,
                      _position.dy + details.delta.dy,
                    );
                  });
                }
              : null,
          child: widget.pictureInPictureConfig.pictureInPictureBuilder(
              AnimatedPreviewFit(
                previewFit: CameraPreviewFit.cover,
                previewSize: PreviewSize(
                  width: 1000,
                  height: 1000 / widget.aspectRatio,
                ), // FIXME  we don't know preview size of other sensors
                constraints: const BoxConstraints(
                  maxWidth: 300,
                  maxHeight: 300,
                ),
                sensor: widget.sensor,
                child: widget.texture,
              ),
              widget.aspectRatio,),
        ),
      ),
    );
}
