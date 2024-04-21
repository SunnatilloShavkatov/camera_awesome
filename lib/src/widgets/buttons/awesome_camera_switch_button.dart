import "package:camera_awesome/src/orchestrator/states/camera_state.dart";
import "package:camera_awesome/src/widgets/utils/awesome_circle_icon.dart";
import "package:camera_awesome/src/widgets/utils/awesome_oriented_widget.dart";
import "package:camera_awesome/src/widgets/utils/awesome_theme.dart";
import "package:flutter/material.dart";

class AwesomeCameraSwitchButton extends StatelessWidget {

  AwesomeCameraSwitchButton({
    super.key,
    required this.state,
    this.theme,
    Widget Function()? iconBuilder,
    void Function(CameraState)? onSwitchTap,
    double scale = 1.3,
  })  : iconBuilder = iconBuilder ??
            (() => AwesomeCircleWidget.icon(
                theme: theme,
                icon: Icons.cameraswitch,
                scale: scale,
              )),
        onSwitchTap = onSwitchTap ?? ((CameraState state) => state.switchCameraSensor());
  final CameraState state;
  final AwesomeTheme? theme;
  final Widget Function() iconBuilder;
  final void Function(CameraState) onSwitchTap;

  @override
  Widget build(BuildContext context) {
    final AwesomeTheme theme = this.theme ?? AwesomeThemeProvider.of(context).theme;

    return AwesomeOrientedWidget(
      rotateWithDevice: theme.buttonTheme.rotateWithCamera,
      child: theme.buttonTheme.buttonBuilder(
        iconBuilder(),
        () => onSwitchTap(state),
      ),
    );
  }
}
