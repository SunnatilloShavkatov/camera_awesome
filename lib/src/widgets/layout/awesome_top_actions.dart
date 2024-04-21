import "package:camera_awesome/src/orchestrator/states/states.dart";
import "package:camera_awesome/src/widgets/buttons/awesome_aspect_ratio_button.dart";
import "package:camera_awesome/src/widgets/buttons/awesome_flash_button.dart";
import "package:camera_awesome/src/widgets/buttons/awesome_location_button.dart";
import "package:flutter/material.dart";

class AwesomeTopActions extends StatelessWidget {

  AwesomeTopActions({
    super.key,
    required this.state,
    List<Widget>? children,
    this.padding = const EdgeInsets.only(left: 30, right: 30, top: 16),
  }) : children = children ??
            (state is VideoRecordingCameraState
                ? <Widget>[const SizedBox.shrink()]
                : <Widget>[
                    AwesomeFlashButton(state: state),
                    if (state is PhotoCameraState)
                      AwesomeAspectRatioButton(state: state),
                    if (state is PhotoCameraState)
                      AwesomeLocationButton(state: state),
                  ]);
  final CameraState state;

  /// Show only children that are relevant to the current [state]
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
}
