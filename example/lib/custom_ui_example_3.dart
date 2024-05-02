// ignore_for_file: discarded_futures

import "package:camera_app/utils/file_utils.dart";
import "package:camera_app/widgets/custom_media_preview.dart";
import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";

class CustomUiExample3 extends StatelessWidget {
  const CustomUiExample3({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CameraAwesomeBuilder.custom(
          builder: (CameraState cameraState, Preview preview) =>
              cameraState.when(
            onPreparingCamera: (PreparingCameraState state) =>
                const Center(child: CircularProgressIndicator()),
            onPhotoMode: TakePhotoUI.new,
            onVideoMode: (VideoCameraState state) =>
                RecordVideoUI(state, recording: false),
            onVideoRecordingMode: (VideoRecordingCameraState state) =>
                RecordVideoUI(state, recording: true),
          ),
          saveConfig: SaveConfig.video(),
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
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            child: Row(
              children: <Widget>[
                AwesomeCaptureButton(state: state),
                const Spacer(),
                StreamBuilder(
                  stream: state.captureState$,
                  builder: (_, AsyncSnapshot<MediaCapture?> snapshot) =>
                      SizedBox(
                    width: 100,
                    height: 100,
                    child: CustomMediaPreview(
                      mediaCapture: snapshot.data,
                      onMediaTap: (MediaCapture mediaCapture) {
                        mediaCapture.captureRequest.when(
                          single: (SingleCaptureRequest single) =>
                              single.file?.open(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
