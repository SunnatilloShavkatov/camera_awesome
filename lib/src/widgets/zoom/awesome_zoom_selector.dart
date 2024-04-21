// ignore_for_file: discarded_futures

import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";

class AwesomeZoomSelector extends StatefulWidget {
  const AwesomeZoomSelector({
    super.key,
    required this.state,
  });

  final CameraState state;

  @override
  State<AwesomeZoomSelector> createState() => _AwesomeZoomSelectorState();
}

class _AwesomeZoomSelectorState extends State<AwesomeZoomSelector> {
  double? minZoom;
  double? maxZoom;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    minZoom = await CamerawesomePlugin.getMinZoom();
    maxZoom = await CamerawesomePlugin.getMaxZoom();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<SensorConfig>(
        stream: widget.state.sensorConfig$,
        builder: (
          BuildContext context,
          AsyncSnapshot<SensorConfig> sensorConfigSnapshot,
        ) {
          initAsync();
          if (sensorConfigSnapshot.data == null ||
              minZoom == null ||
              maxZoom == null) {
            return const SizedBox.shrink();
          }

          return StreamBuilder<double>(
            stream: sensorConfigSnapshot.requireData.zoom$,
            builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
              if (snapshot.hasData) {
                return _ZoomIndicatorLayout(
                  zoom: snapshot.requireData,
                  min: minZoom!,
                  max: maxZoom!,
                  sensorConfig: widget.state.sensorConfig,
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        },
      );
}

class _ZoomIndicatorLayout extends StatelessWidget {
  const _ZoomIndicatorLayout({
    required this.zoom,
    required this.min,
    required this.max,
    required this.sensorConfig,
  });

  final double zoom;
  final double min;
  final double max;
  final SensorConfig sensorConfig;

  @override
  Widget build(BuildContext context) {
    final double displayZoom = (max - min) * zoom + min;
    if (min == 1.0) {
      return _ZoomIndicator(
        normalValue: 0,
        zoom: zoom,
        selected: true,
        min: min,
        max: max,
        sensorConfig: sensorConfig,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Show 3 dots for zooming: min, 1.0X and max zoom. The closer one shows
        // text, the other ones a dot.
        _ZoomIndicator(
          normalValue: 0,
          zoom: zoom,
          selected: displayZoom < 1.0,
          min: min,
          max: max,
          sensorConfig: sensorConfig,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _ZoomIndicator(
            normalValue: (1 - min) / (max - min),
            zoom: zoom,
            selected: !(displayZoom < 1.0 || displayZoom == max),
            min: min,
            max: max,
            sensorConfig: sensorConfig,
          ),
        ),
        _ZoomIndicator(
          normalValue: 1,
          zoom: zoom,
          selected: displayZoom == max,
          min: min,
          max: max,
          sensorConfig: sensorConfig,
        ),
      ],
    );
  }
}

class _ZoomIndicator extends StatelessWidget {
  const _ZoomIndicator({
    required this.zoom,
    required this.min,
    required this.max,
    required this.normalValue,
    required this.sensorConfig,
    required this.selected,
  });

  final double zoom;
  final double min;
  final double max;
  final double normalValue;
  final SensorConfig sensorConfig;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final AwesomeTheme baseTheme = AwesomeThemeProvider.of(context).theme;
    final AwesomeButtonTheme baseButtonTheme = baseTheme.buttonTheme;
    final double displayZoom = (max - min) * zoom + min;
    final Widget content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      transitionBuilder: (Widget child, Animation<double> anim) =>
          ScaleTransition(scale: anim, child: child),
      child: selected
          ? AwesomeBouncingWidget(
              key: ValueKey<String>("zoomIndicator_${normalValue}_selected"),
              onTap: () {
                sensorConfig.setZoom(normalValue);
              },
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.zero,
                child: AwesomeCircleWidget(
                  theme: baseTheme,
                  child: Text(
                    "${displayZoom.toStringAsFixed(1)}X",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            )
          : AwesomeBouncingWidget(
              key: ValueKey<String>("zoomIndicator_${normalValue}_unselected"),
              onTap: () {
                sensorConfig.setZoom(normalValue);
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(16),
                child: AwesomeCircleWidget(
                  theme: baseTheme.copyWith(
                    buttonTheme: baseButtonTheme.copyWith(
                      backgroundColor: baseButtonTheme.foregroundColor,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  child: const SizedBox(width: 6, height: 6),
                ),
              ),
            ),
    );

    // Same width for each dot to keep them in their position
    return SizedBox(
      width: 56,
      child: Center(
        child: content,
      ),
    );
  }
}
