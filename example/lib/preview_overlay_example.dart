// ignore_for_file: discarded_futures

import "dart:async";

import "package:camera_app/utils/file_utils.dart";
import "package:camera_app/utils/mlkit_utils.dart";
import "package:camera_app/widgets/barcode_preview_overlay.dart";
import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";
import "package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart";

void main() {
  runApp(const CameraAwesomeApp());
}

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: "Preview Overlay",
        home: CameraPage(),
      );
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final BarcodeScanner _barcodeScanner =
      BarcodeScanner(formats: <BarcodeFormat>[BarcodeFormat.all]);
  List<Barcode> _barcodes = <Barcode>[];
  AnalysisImage? _image;

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBodyBehindAppBar: true,
        body: CameraAwesomeBuilder.awesome(
          saveConfig: SaveConfig.photoAndVideo(),
          sensorConfig: SensorConfig.single(
            flashMode: FlashMode.auto,
            aspectRatio: CameraAspectRatios.ratio_16_9,
          ),
          previewFit: CameraPreviewFit.fitWidth,
          onMediaTap: (MediaCapture mediaCapture) {
            mediaCapture.captureRequest.when(
              single: (SingleCaptureRequest single) => single.file?.open(),
            );
          },
          previewDecoratorBuilder: (CameraState state, Preview preview) =>
              BarcodePreviewOverlay(
            state: state,
            barcodes: _barcodes,
            analysisImage: _image,
            preview: preview,
          ),
          topActionsBuilder: (CameraState state) => AwesomeTopActions(
            state: state,
            children: <Widget>[
              AwesomeFlashButton(state: state),
              if (state is PhotoCameraState)
                AwesomeAspectRatioButton(state: state),
            ],
          ),
          middleContentBuilder: (CameraState state) => const SizedBox.shrink(),
          bottomActionsBuilder: (CameraState state) => const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              "Scan your barcodes",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ),
          onImageForAnalysis: _processImageBarcode,
          imageAnalysisConfig: AnalysisConfig(
            androidOptions: const AndroidAnalysisOptions.nv21(
              width: 256,
            ),
            maxFramesPerSecond: 3,
          ),
        ),
      );

  Future _processImageBarcode(AnalysisImage img) async {
    try {
      final List<Barcode> recognizedBarCodes =
          await _barcodeScanner.processImage(img.toInputImage());
      setState(() {
        _barcodes = recognizedBarCodes;
        _image = img;
      });
    } on Exception catch (error) {
      debugPrint("...sending image resulted error $error");
    }
  }
}
