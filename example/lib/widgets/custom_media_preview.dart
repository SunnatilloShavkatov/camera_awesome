import "dart:io";

import "package:camera_app/widgets/mini_video_player.dart";
import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class CustomMediaPreview extends StatelessWidget {

  const CustomMediaPreview({
    super.key,
    required this.mediaCapture,
    required this.onMediaTap,
  });
  final MediaCapture? mediaCapture;
  final OnMediaTap onMediaTap;

  @override
  Widget build(BuildContext context) => AwesomeOrientedWidget(
      child: AspectRatio(
        aspectRatio: 1,
        child: AwesomeBouncingWidget(
          onTap: mediaCapture != null && onMediaTap != null
              ? () => onMediaTap!(mediaCapture!)
              : null,
          child: ClipOval(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white38,
                  width: 2,
                ),
              ),
              child: _buildMedia(mediaCapture),
            ),
          ),
        ),
      ),
    );

  Widget _buildMedia(MediaCapture? mediaCapture) {
    switch (mediaCapture?.status) {
      case MediaCaptureStatus.capturing:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Platform.isIOS
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const CircularProgressIndicator(color: Colors.white),
          ),
        );
      case MediaCaptureStatus.success:
        if (mediaCapture!.isPicture) {
          if (kIsWeb) {
            // TODOCheck if that works
            return FutureBuilder<Uint8List>(
                future: mediaCapture.captureRequest.when(
                  single: (SingleCaptureRequest single) => single.file!.readAsBytes(),
                  multiple: (MultipleCaptureRequest multiple) =>
                      multiple.fileBySensor.values.first!.readAsBytes(),
                ),
                builder: (_, AsyncSnapshot<Uint8List> snapshot) {
                  if (snapshot.hasData) {
                    return Image.memory(
                      snapshot.requireData,
                      fit: BoxFit.cover,
                      width: 300,
                    );
                  } else {
                    return Platform.isIOS
                        ? const CupertinoActivityIndicator(
                            color: Colors.white,
                          )
                        : const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          );
                  }
                },);
          } else {
            return Image(
              fit: BoxFit.cover,
              image: ResizeImage(
                FileImage(
                  File(
                    mediaCapture.captureRequest.when(
                      single: (SingleCaptureRequest single) => single.file!.path,
                      multiple: (MultipleCaptureRequest multiple) =>
                          multiple.fileBySensor.values.first!.path,
                    ),
                  ),
                ),
                width: 300,
              ),
            );
          }
        } else {
          return Ink(
            child: MiniVideoPlayer(
              filePath: mediaCapture.captureRequest.when(
                single: (SingleCaptureRequest single) => single.file!.path,
                multiple: (MultipleCaptureRequest multiple) =>
                    multiple.fileBySensor.values.first!.path,
              ),
            ),
          );
        }
      case MediaCaptureStatus.failure:
        return const Icon(Icons.error);
      case null:
        return const SizedBox(
          width: 32,
          height: 32,
        );
    }
  }
}
