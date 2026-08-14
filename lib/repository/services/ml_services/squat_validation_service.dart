import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class SquatMetrics {
  final double kneeAngle;
  final double hipAngle;
  final double trunkAngle;
  final double hipToKneeVerticalRatio;
  final double confidence;
  final bool isBilateral;

  const SquatMetrics({
    required this.kneeAngle,
    required this.hipAngle,
    required this.trunkAngle,
    required this.hipToKneeVerticalRatio,
    required this.confidence,
    required this.isBilateral,
  });

  @override
  String toString() =>
      'SquatMetrics(knee: ${kneeAngle.toStringAsFixed(1)}°, '
      'hip: ${hipAngle.toStringAsFixed(1)}°, '
      'trunk: ${trunkAngle.toStringAsFixed(1)}°, '
      'hipKneeRatio: ${hipToKneeVerticalRatio.toStringAsFixed(2)}, '
      'conf: ${confidence.toStringAsFixed(2)})';
}

class SquatValidationService {
  static const double _minConfidence = 0.45;

  SquatMetrics? getSquatMetrics(Pose pose) {
    final left = _extractSide(pose, left: true);
    final right = _extractSide(pose, left: false);

    final leftConf = left?.confidence;
    final rightConf = right?.confidence;

    if (leftConf == null && rightConf == null) return null;

    final bool bothValid =
        (leftConf ?? 0) >= _minConfidence && (rightConf ?? 0) >= _minConfidence;

    if (bothValid) return _averageMetrics(left!, right!);
    if ((leftConf ?? 0) >= (rightConf ?? 0) && leftConf! >= _minConfidence) {
      return left;
    }
    if (rightConf != null && rightConf >= _minConfidence) return right;
    return null;
  }

  double? getSquatAngle(Pose pose) => getSquatMetrics(pose)?.kneeAngle;

  _SideLandmarks? _extractSide(Pose pose, {required bool left}) {
    final hipType = left ? PoseLandmarkType.leftHip : PoseLandmarkType.rightHip;
    final kneeType = left
        ? PoseLandmarkType.leftKnee
        : PoseLandmarkType.rightKnee;
    final ankleType = left
        ? PoseLandmarkType.leftAnkle
        : PoseLandmarkType.rightAnkle;
    final shoulderType = left
        ? PoseLandmarkType.leftShoulder
        : PoseLandmarkType.rightShoulder;

    final hip = pose.landmarks[hipType];
    final knee = pose.landmarks[kneeType];
    final ankle = pose.landmarks[ankleType];
    final shoulder = pose.landmarks[shoulderType];

    if (hip == null || knee == null || ankle == null || shoulder == null) {
      return null;
    }

    final confidence = [
      hip.likelihood,
      knee.likelihood,
      ankle.likelihood,
      shoulder.likelihood,
    ].reduce(min);

    if (confidence < _minConfidence) return null;

    final kneeAngle = _calculateAngle(hip, knee, ankle);
    final hipAngle = _calculateAngle(shoulder, hip, knee);
    final trunkAngle = _calculateTrunkAngle(shoulder, hip);
    final hipToKneeRatio = _hipToKneeVerticalRatio(hip, knee);

    return _SideLandmarks(
      kneeAngle: kneeAngle,
      hipAngle: hipAngle,
      trunkAngle: trunkAngle,
      hipToKneeVerticalRatio: hipToKneeRatio,
      confidence: confidence,
    );
  }

  SquatMetrics _averageMetrics(_SideLandmarks l, _SideLandmarks r) {
    return SquatMetrics(
      kneeAngle: (l.kneeAngle + r.kneeAngle) / 2,
      hipAngle: (l.hipAngle + r.hipAngle) / 2,
      trunkAngle: (l.trunkAngle + r.trunkAngle) / 2,
      hipToKneeVerticalRatio:
          (l.hipToKneeVerticalRatio + r.hipToKneeVerticalRatio) / 2,
      confidence: (l.confidence + r.confidence) / 2,
      isBilateral: true,
    );
  }

  double _calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final radians = atan2(c.y - b.y, c.x - b.x) - atan2(a.y - b.y, a.x - b.x);
    double angle = (radians * 180 / pi).abs();
    if (angle > 180) angle = 360 - angle;
    return angle;
  }

  double _calculateTrunkAngle(PoseLandmark shoulder, PoseLandmark hip) {
    final dy = hip.y - shoulder.y;
    final dx = hip.x - shoulder.x;
    return atan2(dx.abs(), dy.abs()) * 180 / pi;
  }

  double _hipToKneeVerticalRatio(PoseLandmark hip, PoseLandmark knee) {
    final femurLength = sqrt(pow(knee.x - hip.x, 2) + pow(knee.y - hip.y, 2));
    if (femurLength < 1e-6) return 0;
    return (knee.y - hip.y) / femurLength;
  }
}

class _SideLandmarks extends SquatMetrics {
  const _SideLandmarks({
    required super.kneeAngle,
    required super.hipAngle,
    required super.trunkAngle,
    required super.hipToKneeVerticalRatio,
    required super.confidence,
  }) : super(isBilateral: false);
}
