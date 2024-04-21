import "package:camera_awesome/src/orchestrator/models/models.dart";
import "package:camera_awesome/src/orchestrator/states/photo_camera_state.dart";
import "package:camera_awesome/src/widgets/utils/awesome_circle_icon.dart";
import "package:camera_awesome/src/widgets/utils/awesome_oriented_widget.dart";
import "package:camera_awesome/src/widgets/utils/awesome_theme.dart";
import "package:flutter/material.dart";

class AwesomeAspectRatioButton extends StatelessWidget {

  AwesomeAspectRatioButton({
    super.key,
    required this.state,
    this.theme,
    Widget Function(CameraAspectRatios aspectRatio)? iconBuilder,
    void Function(SensorConfig sensorConfig, CameraAspectRatios aspectRatio)?
        onAspectRatioTap,
  })  : iconBuilder = iconBuilder ??
            ((CameraAspectRatios aspectRatio) {
              final AssetImage icon;
              double width;
              switch (aspectRatio) {
                case CameraAspectRatios.ratio_16_9:
                  width = 32;
                  icon = const AssetImage(
                      "packages/camerawesome/assets/icons/16_9.png",);
                case CameraAspectRatios.ratio_4_3:
                  width = 24;
                  icon = const AssetImage(
                      "packages/camerawesome/assets/icons/4_3.png",);
                case CameraAspectRatios.ratio_1_1:
                  width = 24;
                  icon = const AssetImage(
                      "packages/camerawesome/assets/icons/1_1.png",);
              }

              return Builder(builder: (BuildContext context) {
                final double iconSize = theme?.buttonTheme.iconSize ??
                    AwesomeThemeProvider.of(context).theme.buttonTheme.iconSize;

                final double scaleRatio = iconSize / AwesomeButtonTheme.baseIconSize;
                return AwesomeCircleWidget(
                  theme: theme,
                  child: Center(
                    child: SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: FittedBox(
                        child: Builder(
                          builder: (BuildContext context) => Image(
                            image: icon,
                            color: AwesomeThemeProvider.of(context)
                                .theme
                                .buttonTheme
                                .foregroundColor,
                            width: width * scaleRatio,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },);
            }),
        onAspectRatioTap = onAspectRatioTap ??
            ((SensorConfig sensorConfig, CameraAspectRatios aspectRatio) => sensorConfig.switchCameraRatio());
  final PhotoCameraState state;
  final AwesomeTheme? theme;
  final Widget Function(CameraAspectRatios aspectRatio) iconBuilder;
  final void Function(SensorConfig sensorConfig, CameraAspectRatios aspectRatio)
      onAspectRatioTap;

  @override
  Widget build(BuildContext context) {
    final AwesomeTheme theme = this.theme ?? AwesomeThemeProvider.of(context).theme;
    return StreamBuilder<SensorConfig>(
      key: const ValueKey("ratioButton"),
      stream: state.sensorConfig$,
      builder: (_, AsyncSnapshot<SensorConfig> sensorConfigSnapshot) {
        if (!sensorConfigSnapshot.hasData) {
          return const SizedBox.shrink();
        }
        final SensorConfig sensorConfig = sensorConfigSnapshot.requireData;
        return StreamBuilder<CameraAspectRatios>(
          stream: sensorConfig.aspectRatio$,
          builder: (BuildContext context, AsyncSnapshot<CameraAspectRatios> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            return AwesomeOrientedWidget(
              rotateWithDevice: theme.buttonTheme.rotateWithCamera,
              child: theme.buttonTheme.buttonBuilder(
                iconBuilder(snapshot.requireData),
                () => onAspectRatioTap(sensorConfig, snapshot.requireData),
              ),
            );
          },
        );
      },
    );
  }
}
