import "dart:io";

import "package:camera_awesome/src/orchestrator/models/capture_request.dart";
import "package:camera_awesome/src/orchestrator/models/media_capture.dart";
import "package:camera_awesome/src/widgets/camera_awesome_builder.dart";
import "package:camera_awesome/src/widgets/utils/awesome_bouncing_widget.dart";
import "package:camera_awesome/src/widgets/utils/awesome_oriented_widget.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class AwesomeMediaPreview extends StatelessWidget {

  const AwesomeMediaPreview({
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
          onTap: mediaCapture != null &&
                  onMediaTap != null &&
                  mediaCapture?.status == MediaCaptureStatus.success
              ? () => onMediaTap!(mediaCapture!)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white30,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white38,
                width: 2,
              ),
            ),
            child: ClipOval(child: _buildMedia(mediaCapture)),
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
                ? const CupertinoActivityIndicator(
                    color: Colors.white,
                  )
                : const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
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
          return const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
          );
        }
      case MediaCaptureStatus.failure:
        return const Icon(
          Icons.error,
          color: Colors.white,
        );
      case null:
        return const SizedBox(
          width: 32,
          height: 32,
        );
    }
  }
}
