// ignore_for_file: discarded_futures

import "dart:io";

import "package:flutter/material.dart";
import "package:video_player/video_player.dart";

class MiniVideoPlayer extends StatefulWidget {
  const MiniVideoPlayer({super.key, required this.filePath});

  final String filePath;

  @override
  State<StatefulWidget> createState() => _MiniVideoPlayer();
}

class _MiniVideoPlayer extends State<MiniVideoPlayer> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then(
        (value) => setState(() {
          _controller?.setLooping(true);
          _controller?.play();
        }),
      );
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _controller?.value.isInitialized != true) {
      return const Center(child: CircularProgressIndicator());
    }
    return VideoPlayer(_controller!);
  }
}
