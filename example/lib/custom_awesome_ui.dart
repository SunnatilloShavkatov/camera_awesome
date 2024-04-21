// ignore_for_file: discarded_futures

import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";

void main() {
  runApp(const CameraAwesomeApp());
}

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: "Custom CamerAwesome UI",
        home: CameraPage(),
      );
}

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CameraAwesomeBuilder.awesome(
          saveConfig: SaveConfig.photo(),
          sensorConfig: SensorConfig.single(
            sensor: Sensor.position(SensorPosition.back),
            aspectRatio: CameraAspectRatios.ratio_1_1,
          ),
          previewFit: CameraPreviewFit.contain,
          previewPadding: const EdgeInsets.only(left: 150, top: 100),
          previewAlignment: Alignment.topRight,
          // Buttons of CamerAwesome UI will use this theme
          theme: AwesomeTheme(
            bottomActionsBackgroundColor: Colors.cyan.withOpacity(0.5),
            buttonTheme: AwesomeButtonTheme(
              backgroundColor: Colors.cyan.withOpacity(0.5),
              iconSize: 20,
              padding: const EdgeInsets.all(16),
              // Tap visual feedback (ripple, bounce...)
              buttonBuilder: (Widget child, onTap) => ClipOval(
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    splashColor: Colors.cyan,
                    highlightColor: Colors.cyan.withOpacity(0.5),
                    onTap: onTap,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
          topActionsBuilder: (CameraState state) => AwesomeTopActions(
            padding: EdgeInsets.zero,
            state: state,
            children: <Widget>[
              Expanded(
                child: AwesomeFilterWidget(
                  state: state,
                  filterListPosition: FilterListPosition.aboveButton,
                  filterListPadding: const EdgeInsets.only(top: 8),
                ),
              ),
            ],
          ),
          middleContentBuilder: (CameraState state) => Column(
            children: <Widget>[
              const Spacer(),
              Builder(
                builder: (BuildContext context) => ColoredBox(
                  color: AwesomeThemeProvider.of(context)
                      .theme
                      .bottomActionsBackgroundColor,
                  child: const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text(
                        "Take your best shot!",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomActionsBuilder: (CameraState state) => AwesomeBottomActions(
            state: state,
            left: AwesomeFlashButton(
              state: state,
            ),
            right: AwesomeCameraSwitchButton(
              state: state,
              scale: 1,
              onSwitchTap: (CameraState state) {
                state.switchCameraSensor(
                  aspectRatio: state.sensorConfig.aspectRatio,
                );
              },
            ),
          ),
        ),
      );
}
