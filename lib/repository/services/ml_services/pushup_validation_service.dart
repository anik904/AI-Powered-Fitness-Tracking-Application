import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PushupMetrics {
  final double wristShoulderYRatio;
  final double elbowFlareRatio;
  final double plankDeviation;
  final double shoulderAsymmetry;
  final bool isInPushupPosition;
  final double confidence;

  const PushupMetrics({
    required this.wristShoulderYRatio,
    required this.elbowFlareRatio,
    required this.plankDeviation,
    required this.shoulderAsymmetry,
    required this.isInPushupPosition,
    required this.confidence,
  });

  @override
  String toString() =>
      'PushupMetrics('
      'wristY: ${wristShoulderYRatio.toStringAsFixed(2)}, '
      'elbowFlare: ${elbowFlareRatio.toStringAsFixed(2)}, '
      'plank: ${plankDeviation.toStringAsFixed(2)}, '
      'inPos: $isInPushupPosition)';
}

class PushupValidationService {
  // Lower threshold — floor-level poses score poorly in MLKit
  static const double _minConfidence = 0.30;

  PushupMetrics? getPushupMetrics(Pose pose) {
    final landmarks = pose.landmarks;

    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];

    if ([
      leftShoulder,
      rightShoulder,
      leftElbow,
      rightElbow,
      leftWrist,
      rightWrist,
    ].any((l) => l == null || l.likelihood < _minConfidence)) {
      return null;
    }

    final shoulderWidth = (leftShoulder!.x - rightShoulder!.x).abs();
    if (shoulderWidth < 0.08) return null;


    final avgShoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final avgWristY = (leftWrist!.y + rightWrist!.y) / 2;
    final avgelbowxWidth = (leftElbow!.x - rightElbow!.x).abs();

    final wristShoulderYRatio = (avgWristY - avgShoulderY) / shoulderWidth;
    final elbowFlareRatio = (avgelbowxWidth - shoulderWidth) / shoulderWidth;

    double plankDeviation = 0.0;
    final avgHipY =
        leftHip != null &&
            rightHip != null &&
            leftHip.likelihood >= _minConfidence &&
            rightHip.likelihood >= _minConfidence
        ? (leftHip.y + rightHip.y) / 2
        : null;

    if (avgHipY != null) {
      plankDeviation = (avgHipY - avgShoulderY) / shoulderWidth;
    }

    final shoulderAsymmetry = (leftShoulder.y - rightShoulder.y).abs() / shoulderWidth;
    final isInPushupPosition = wristShoulderYRatio > 0.40;

    final confidence = [
      leftShoulder.likelihood,
      rightShoulder.likelihood,
      leftElbow.likelihood,
      rightElbow.likelihood,
      leftWrist.likelihood,
      rightWrist.likelihood,
    ].reduce(min);

    return PushupMetrics(
      wristShoulderYRatio: wristShoulderYRatio,
      elbowFlareRatio: elbowFlareRatio.clamp(-1.0, 3.0),
      plankDeviation: plankDeviation,
      shoulderAsymmetry: shoulderAsymmetry,
      isInPushupPosition: isInPushupPosition,
      confidence: confidence,
    );
  }
}
