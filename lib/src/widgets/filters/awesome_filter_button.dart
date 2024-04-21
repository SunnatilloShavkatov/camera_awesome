import "package:camera_awesome/src/orchestrator/models/camera_flashes.dart";
import "package:camera_awesome/src/orchestrator/models/sensor_config.dart";
import "package:camera_awesome/src/orchestrator/states/camera_state.dart";
import "package:camera_awesome/src/widgets/utils/awesome_circle_icon.dart";
import "package:camera_awesome/src/widgets/utils/awesome_oriented_widget.dart";
import "package:camera_awesome/src/widgets/utils/awesome_theme.dart";
import "package:flutter/material.dart";

class AwesomeFilterButton extends StatelessWidget {

  AwesomeFilterButton({
    super.key,
    required this.state,
    this.theme,
    Widget Function()? iconBuilder,
    final void Function()? onFilterTap,
  })  : iconBuilder = iconBuilder ??
            (() => AwesomeCircleWidget.icon(
                icon: Icons.filter_rounded,
                theme: theme,
              )),
        onFilterTap = onFilterTap ?? (state.toggleFilterSelector);
  final CameraState state;
  final AwesomeTheme? theme;
  final Widget Function() iconBuilder;
  final void Function() onFilterTap;

  @override
  Widget build(BuildContext context) {
    final AwesomeTheme theme = this.theme ?? AwesomeThemeProvider.of(context).theme;
    return StreamBuilder<SensorConfig>(
      stream: state.sensorConfig$,
      builder: (_, AsyncSnapshot<SensorConfig> sensorConfigSnapshot) {
        if (!sensorConfigSnapshot.hasData) {
          return const SizedBox.shrink();
        }
        final SensorConfig sensorConfig = sensorConfigSnapshot.requireData;
        return StreamBuilder<FlashMode>(
          stream: sensorConfig.flashMode$,
          builder: (BuildContext context, AsyncSnapshot<FlashMode> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            return AwesomeOrientedWidget(
              rotateWithDevice: theme.buttonTheme.rotateWithCamera,
              child: theme.buttonTheme.buttonBuilder(
                iconBuilder(),
                onFilterTap,
              ),
            );
          },
        );
      },
    );
  }
}
