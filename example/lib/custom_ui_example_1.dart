import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";

class CustomUiExample1 extends StatelessWidget {
  const CustomUiExample1({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      body: CameraAwesomeBuilder.custom(
        builder: (CameraState cameraState, Preview preview) => cameraState.when(
            onPreparingCamera: (PreparingCameraState state) =>
                const Center(child: CircularProgressIndicator()),
            onPhotoMode: TakePhotoUI.new,
            onVideoMode: (VideoCameraState state) => RecordVideoUI(state, recording: false),
            onVideoRecordingMode: (VideoRecordingCameraState state) =>
                RecordVideoUI(state, recording: true),
          ),
        saveConfig: SaveConfig.photoAndVideo(),
      ),
    );
}

class TakePhotoUI extends StatelessWidget {

  const TakePhotoUI(this.state, {super.key});
  final PhotoCameraState state;

  @override
  Widget build(BuildContext context) => Container();
}

class RecordVideoUI extends StatelessWidget {

  const RecordVideoUI(this.state, {super.key, required this.recording});
  final CameraState state;
  final bool recording;

  @override
  Widget build(BuildContext context) => Container();
}
