import "package:camera_awesome/src/orchestrator/models/camera_flashes.dart";
import "package:camera_awesome/src/orchestrator/models/sensor_config.dart";
import "package:camera_awesome/src/orchestrator/states/camera_state.dart";
import "package:camera_awesome/src/widgets/utils/awesome_circle_icon.dart";
import "package:camera_awesome/src/widgets/utils/awesome_oriented_widget.dart";
import "package:camera_awesome/src/widgets/utils/awesome_theme.dart";
import "package:flutter/material.dart";

class AwesomeFlashButton extends StatelessWidget {

  AwesomeFlashButton({
    super.key,
    required this.state,
    this.theme,
    Widget Function(FlashMode)? iconBuilder,
    void Function(SensorConfig, FlashMode)? onFlashTap,
  })  : iconBuilder = iconBuilder ??
            ((FlashMode flashMode) {
              final IconData icon;
              switch (flashMode) {
                case FlashMode.none:
                  icon = Icons.flash_off;
                case FlashMode.on:
                  icon = Icons.flash_on;
                case FlashMode.auto:
                  icon = Icons.flash_auto;
                case FlashMode.always:
                  icon = Icons.flashlight_on;
              }
              return AwesomeCircleWidget.icon(
                icon: icon,
                theme: theme,
              );
            }),
        onFlashTap = onFlashTap ??
            ((SensorConfig sensorConfig, FlashMode flashMode) => sensorConfig.switchCameraFlash());
  final CameraState state;
  final AwesomeTheme? theme;
  final Widget Function(FlashMode) iconBuilder;
  final void Function(SensorConfig, FlashMode) onFlashTap;

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
                iconBuilder(snapshot.requireData),
                () => onFlashTap(sensorConfig, snapshot.requireData),
              ),
            );
          },
        );
      },
    );
  }
}
