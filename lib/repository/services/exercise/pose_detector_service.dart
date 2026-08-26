import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectorService {
  PoseDetector? _detector;
  bool _isProcessing = false;

  void initialize() {
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
  }

  Future<List<Pose>?> processFrame(
    CameraImage image,
    InputImageRotation rotation,
  ) async {
    if (_isProcessing || _detector == null) return null;

    _isProcessing = true;

    try {
      final inputImage = _buildInputImage(image, rotation);
      if (inputImage == null) return null;
      final poses = await _detector!.processImage(inputImage);
      return poses;
    } catch (e) {
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _buildInputImage(CameraImage image, InputImageRotation rotation) {
    try {
      final plane = image.planes.first;
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: Platform.isAndroid 
              ? InputImageFormat.nv21 
              : InputImageFormat.bgra8888,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> dispose() async {
    await _detector?.close();
    _detector = null;
  }
}