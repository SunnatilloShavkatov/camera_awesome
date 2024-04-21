import "package:camera_awesome/src/orchestrator/models/media_capture.dart";
import "package:camera_awesome/src/orchestrator/states/states.dart";
import "package:camera_awesome/src/widgets/awesome_media_preview.dart";
import "package:camera_awesome/src/widgets/buttons/awesome_camera_switch_button.dart";
import "package:camera_awesome/src/widgets/buttons/awesome_capture_button.dart";
import "package:camera_awesome/src/widgets/buttons/awesome_pause_resume_button.dart";
import "package:camera_awesome/src/widgets/camera_awesome_builder.dart";
import "package:camera_awesome/src/widgets/utils/awesome_theme.dart";
import "package:flutter/material.dart";

class AwesomeBottomActions extends StatelessWidget {

  AwesomeBottomActions({
    super.key,
    required this.state,
    Widget? left,
    Widget? right,
    Widget? captureButton,
    OnMediaTap? onMediaTap,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  })  : captureButton = captureButton ??
            AwesomeCaptureButton(
              state: state,
            ),
        left = left ??
            (state is VideoRecordingCameraState
                ? AwesomePauseResumeButton(
                    state: state,
                  )
                : Builder(builder: (BuildContext context) {
                    final AwesomeTheme theme = AwesomeThemeProvider.of(context).theme;
                    return AwesomeCameraSwitchButton(
                      state: state,
                      theme: theme.copyWith(
                        buttonTheme: theme.buttonTheme.copyWith(
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    );
                  },)),
        right = right ??
            (state is VideoRecordingCameraState
                ? const SizedBox(width: 48)
                : StreamBuilder<MediaCapture?>(
                    stream: state.captureState$,
                    builder: (BuildContext context, AsyncSnapshot<MediaCapture?> snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(width: 60, height: 60);
                      }
                      return SizedBox(
                        width: 60,
                        child: AwesomeMediaPreview(
                          mediaCapture: snapshot.requireData,
                          onMediaTap: onMediaTap,
                        ),
                      );
                    },
                  ));
  final CameraState state;
  final Widget left;
  final Widget right;
  final Widget captureButton;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Center(
              child: left,
            ),
          ),
          captureButton,
          Expanded(
            child: Center(
              child: right,
            ),
          ),
        ],
      ),
    );
}
