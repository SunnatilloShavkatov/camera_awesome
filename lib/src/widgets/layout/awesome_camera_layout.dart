// ignore_for_file: unused_import

import "dart:io";

import "package:camera_awesome/src/orchestrator/models/capture_modes.dart";
import "package:camera_awesome/src/orchestrator/states/states.dart";
import "package:camera_awesome/src/widgets/awesome_camera_mode_selector.dart";
import "package:camera_awesome/src/widgets/camera_awesome_builder.dart";
import "package:camera_awesome/src/widgets/filters/awesome_filter_widget.dart";
import "package:camera_awesome/src/widgets/layout/layout.dart";
import "package:camera_awesome/src/widgets/utils/awesome_theme.dart";
import "package:camera_awesome/src/widgets/zoom/awesome_zoom_selector.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// This widget doesn't handle [PreparingCameraState]
class AwesomeCameraLayout extends StatelessWidget {

  AwesomeCameraLayout({
    super.key,
    required this.state,
    OnMediaTap? onMediaTap,
    Widget? middleContent,
    Widget? topActions,
    Widget? bottomActions,
  })  : middleContent = middleContent ??
            (Column(
              children: <Widget>[
                const Spacer(),
                if (state is PhotoCameraState && state.hasFilters)
                  AwesomeFilterWidget(state: state)
                else if (!kIsWeb && Platform.isAndroid)
                  AwesomeZoomSelector(state: state),
                AwesomeCameraModeSelector(state: state),
              ],
            )),
        topActions = topActions ?? AwesomeTopActions(state: state),
        bottomActions = bottomActions ??
            AwesomeBottomActions(state: state, onMediaTap: onMediaTap);
  final CameraState state;
  final Widget middleContent;
  final Widget topActions;
  final Widget bottomActions;

  @override
  Widget build(BuildContext context) {
    final AwesomeTheme theme = AwesomeThemeProvider.of(context).theme;
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          topActions,
          Expanded(child: middleContent),
          ColoredBox(
            color: theme.bottomActionsBackgroundColor,
            child: SafeArea(
              top: false,
              child: Column(
                children: <Widget>[
                  bottomActions,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
