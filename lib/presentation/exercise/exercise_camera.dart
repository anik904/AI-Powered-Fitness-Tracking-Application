import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';


typedef CameraOverlayBuilder = Widget Function(BuildContext context, Size imageSize);

class ExerciseCamera extends StatefulWidget {
  final void Function(CameraImage image, InputImageRotation rotation) onImage;
  final CameraLensDirection lensDirection;
  final CameraOverlayBuilder? overlayBuilder;

  const ExerciseCamera({
    super.key,
    required this.onImage,
    this.lensDirection = CameraLensDirection.front,
    this.overlayBuilder,
  });

  @override
  State<ExerciseCamera> createState() => _ExerciseCameraState();
}

class _ExerciseCameraState extends State<ExerciseCamera> {
  CameraController? _controller;
  bool _cameraReady = false;
  InputImageRotation _rotation = InputImageRotation.rotation0deg;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == widget.lensDirection,
      orElse: () => cameras.first,
    );
    _rotation = _rotationFromCamera(camera);
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid 
          ? ImageFormatGroup.nv21 
          : ImageFormatGroup.bgra8888,
    );
    await _controller!.initialize();
    if (!mounted) return;
    _controller!.startImageStream((image) {
      if (mounted) {
        widget.onImage(image, _rotation);
      }
    });
    if (mounted) setState(() => _cameraReady = true);
  }

  InputImageRotation _rotationFromCamera(CameraDescription camera) {
    switch (camera.sensorOrientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraReady || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final previewSize = _controller!.value.previewSize!;
    final imageSize = Size(previewSize.height, previewSize.width);
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: imageSize.width,
          height: imageSize.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_controller!),
              if (widget.overlayBuilder != null)
                widget.overlayBuilder!(context, imageSize),
            ],
          ),
        ),
      ),
    );
  }
}