import "dart:math";

import "package:camera_awesome/camerawesome_plugin.dart";
import "package:camera_awesome/pigeon.dart";
import "package:flutter/material.dart";

/// Tap to take a photo example, with almost no UI
class CustomUiExample2 extends StatelessWidget {
  const CustomUiExample2({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      body: CameraAwesomeBuilder.custom(
        builder: (CameraState cameraState, Preview preview) => Stack(
            children: <Widget>[
              const Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Text(
                      "Tap to take a photo",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    width: 100,
                    child: StreamBuilder<MediaCapture?>(
                      stream: cameraState.captureState$,
                      builder: (_, AsyncSnapshot<MediaCapture?> snapshot) {
                        if (snapshot.data == null) {
                          return const SizedBox.shrink();
                        }
                        return AwesomeMediaPreview(
                          mediaCapture: snapshot.data,
                          onMediaTap: (MediaCapture mediaCapture) {
                            // ignore: avoid_print
                            print("Tap on $mediaCapture");
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        saveConfig: SaveConfig.photo(),
        onPreviewTapBuilder: (CameraState state) => OnPreviewTap(
          onTap: (Offset position, PreviewSize flutterPreviewSize,
              PreviewSize pixelPreviewSize,) {
            state.when(onPhotoMode: (PhotoCameraState picState) => picState.takePhoto());
          },
          onTapPainter: (Offset tapPosition) => TweenAnimationBuilder(
            key: ValueKey(tapPosition),
            tween: Tween<double>(begin: 1, end: 0),
            duration: const Duration(milliseconds: 500),
            builder: (BuildContext context, double anim, Widget? child) => Transform.rotate(
                angle: anim * 2 * pi,
                child: Transform.scale(
                  scale: 4 * anim,
                  child: child,
                ),
              ),
            child: const Icon(
              Icons.camera,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
}
