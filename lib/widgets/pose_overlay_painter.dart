import 'package:ai_fitness_tracker/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseOverlayPainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final bool isFrontCamera;

  PoseOverlayPainter({
    required this.poses,
    required this.imageSize,
    this.isFrontCamera = false,
  });

  final _linePaint = Paint()
    ..color = AppColors.warning
    ..strokeWidth = 5.0
    ..style = PaintingStyle.stroke;

  final _handLinePaint = Paint()
    ..color = AppColors.warning
    ..strokeWidth = 2.5
    ..style = PaintingStyle.stroke;

  final _footLinePaint = Paint()
    ..color = AppColors.warning
    ..strokeWidth = 2.5
    ..style = PaintingStyle.stroke;

  final _dotPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  static const _bodyConnections = [
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
  ];

  // ML Kit only gives 3 hand landmarks per hand:
  // wrist (from body), thumb, index, pinky.
  // Connect them as a triangle fan from wrist + span thumb→index→pinky.
  static const _handConnections = [
    // Left hand
    [PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb],
    [PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndex],
    [PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinky],
    [PoseLandmarkType.leftThumb, PoseLandmarkType.leftIndex],
    [PoseLandmarkType.leftIndex, PoseLandmarkType.leftPinky],
    // Right hand
    [PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb],
    [PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndex],
    [PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinky],
    [PoseLandmarkType.rightThumb, PoseLandmarkType.rightIndex],
    [PoseLandmarkType.rightIndex, PoseLandmarkType.rightPinky],
  ];

  // Foot triangle: ankle → heel → footIndex → ankle (closed).
  static const _footConnections = [
    // Left foot
    [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel],
    [PoseLandmarkType.leftHeel, PoseLandmarkType.leftFootIndex],
    [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftFootIndex],
    // Right foot
    [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel],
    [PoseLandmarkType.rightHeel, PoseLandmarkType.rightFootIndex],
    [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightFootIndex],
  ];

  static const _faceLandmarks = {
    PoseLandmarkType.nose,
    PoseLandmarkType.leftEye,
    PoseLandmarkType.rightEye,
    PoseLandmarkType.leftEyeInner,
    PoseLandmarkType.leftEyeOuter,
    PoseLandmarkType.rightEyeInner,
    PoseLandmarkType.rightEyeOuter,
    PoseLandmarkType.leftEar,
    PoseLandmarkType.rightEar,
    PoseLandmarkType.leftMouth,
    PoseLandmarkType.rightMouth,
  };

  @override
  void paint(Canvas canvas, Size size) {
    for (final pose in poses) {
      if (_isValidPose(pose)) {
        _drawConnections(canvas, size, pose, _bodyConnections, _linePaint);
        _drawConnections(canvas, size, pose, _handConnections, _handLinePaint);
        _drawConnections(canvas, size, pose, _footConnections, _footLinePaint);
        _drawLandmarks(canvas, size, pose);
      }
    }
  }

  bool _isValidPose(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    return leftShoulder != null && leftShoulder.likelihood > 0.5 &&
        rightShoulder != null && rightShoulder.likelihood > 0.5 &&
        leftHip != null && leftHip.likelihood > 0.5 &&
        rightHip != null && rightHip.likelihood > 0.5;
  }

  void _drawConnections(
    Canvas canvas,
    Size size,
    Pose pose,
    List<List<PoseLandmarkType>> connections,
    Paint paint,
  ) {
    for (final connection in connections) {
      final start = pose.landmarks[connection[0]];
      final end = pose.landmarks[connection[1]];
      if (start == null || end == null) continue;
      if (start.likelihood < 0.5 || end.likelihood < 0.5) continue;
      canvas.drawLine(
        _translate(start.x, start.y, size),
        _translate(end.x, end.y, size),
        paint,
      );
    }
  }

  void _drawLandmarks(Canvas canvas, Size size, Pose pose) {
    for (final entry in pose.landmarks.entries) {
      final type = entry.key;
      final landmark = entry.value;
      if (landmark.likelihood < 0.5) continue;
      if (_faceLandmarks.contains(type)) continue;
      canvas.drawCircle(
        _translate(landmark.x, landmark.y, size),
        5,
        _dotPaint,
      );
    }
  }

  Offset _translate(double x, double y, Size size) {
    double translatedX = x / imageSize.width * size.width;
    if (isFrontCamera) translatedX = size.width - translatedX;
    final translatedY = y / imageSize.height * size.height;
    return Offset(translatedX, translatedY);
  }

  @override
  bool shouldRepaint(PoseOverlayPainter oldDelegate) => true;
}