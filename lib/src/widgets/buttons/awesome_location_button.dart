import "package:camera_awesome/src/orchestrator/states/photo_camera_state.dart";
import "package:camera_awesome/src/widgets/utils/awesome_circle_icon.dart";
import "package:camera_awesome/src/widgets/utils/awesome_oriented_widget.dart";
import "package:camera_awesome/src/widgets/utils/awesome_theme.dart";
import "package:flutter/material.dart";

class AwesomeLocationButton extends StatelessWidget {

  AwesomeLocationButton({
    super.key,
    required this.state,
    this.theme,
    Widget Function(bool saveGpsLocation)? iconBuilder,
    void Function(PhotoCameraState state, bool saveGpsLocation)? onLocationTap,
  })  : iconBuilder = iconBuilder ??
            ((bool saveGpsLocation) => AwesomeCircleWidget.icon(
                theme: theme,
                icon: saveGpsLocation
                    ? Icons.location_pin
                    : Icons.location_off_outlined,
              )),
        onLocationTap = onLocationTap ??
            ((PhotoCameraState state, bool saveGpsLocation) =>
                state.shouldSaveGpsLocation(saveGpsLocation));
  final PhotoCameraState state;
  final AwesomeTheme? theme;
  final Widget Function(bool saveGpsLocation) iconBuilder;
  final void Function(PhotoCameraState state, bool saveGpsLocation)
      onLocationTap;

  @override
  Widget build(BuildContext context) {
    final AwesomeTheme theme = this.theme ?? AwesomeThemeProvider.of(context).theme;
    return StreamBuilder<bool>(
      stream: state.saveGpsLocation$,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return AwesomeOrientedWidget(
          rotateWithDevice: theme.buttonTheme.rotateWithCamera,
          child: theme.buttonTheme.buttonBuilder(
            iconBuilder(snapshot.requireData),
            () => onLocationTap(state, !snapshot.requireData),
          ),
        );
      },
    );
  }
}
