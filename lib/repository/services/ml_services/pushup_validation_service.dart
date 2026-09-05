// pushup_validation_service.dart

import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PushupMetrics {
  /// Primary depth signal — no calibration needed.
  /// Measures how close wrists are to shoulders in Y, normalised by
  /// shoulder width.
  ///
  /// TOP:    wrists are BELOW shoulders → large positive value (~0.8–1.5)
  /// BOTTOM: wrists are NEAR shoulder level → small value (~0.0–0.3)
  final double wristShoulderYRatio;

  /// Elbow flare: how much wider elbows are than shoulders.
  /// Normalised by shoulder width.
  /// TOP:    elbows slightly outside shoulders (~0.1–0.3)
  /// BOTTOM: elbows flare visibly wider (~0.4–0.8)
  final double elbowFlareRatio;

  /// Plank quality: hip Y relative to shoulder Y, normalised by shoulder width.
  /// Near 0.0 = flat. Large positive = hips sagging. Large negative = piked.
  final double plankDeviation;

  /// Shoulder tilt left-to-right, normalised by shoulder width.
  final double shoulderAsymmetry;

  /// Whether all positional checks passed for a valid push-up plank.
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

    final leftShoulder  = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow     = landmarks[PoseLandmarkType.leftElbow];
    final rightElbow    = landmarks[PoseLandmarkType.rightElbow];
    final leftWrist     = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist    = landmarks[PoseLandmarkType.rightWrist];
    final leftHip       = landmarks[PoseLandmarkType.leftHip];
    final rightHip      = landmarks[PoseLandmarkType.rightHip];
    final leftKnee      = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee     = landmarks[PoseLandmarkType.rightKnee];

    // Shoulders, elbows, wrists are mandatory
    if ([
      leftShoulder, rightShoulder,
      leftElbow,    rightElbow,
      leftWrist,    rightWrist,
    ].any((l) => l == null || l.likelihood < _minConfidence)) {
      return null;
    }

    final shoulderWidth = (leftShoulder!.x - rightShoulder!.x).abs();
    if (shoulderWidth < 0.08) return null; // too far away or sideways

    // ── Core measurements ──────────────────────────────────────────────────

    final avgShoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final avgWristY    = (leftWrist!.y   + rightWrist!.y)   / 2;
    final avgelbowxWidth = (leftElbow!.x - rightElbow!.x).abs();

    // ── Signal 1: Wrist-to-Shoulder Y ratio ───────────────────────────────
    //
    // At TOP: arms extended, wrists are far below shoulders.
    //   avgWristY >> avgShoulderY  → large positive ratio
    //
    // At BOTTOM: chest near floor, wrists are near shoulder height.
    //   avgWristY ≈ avgShoulderY  → ratio near 0
    //
    // (Y increases downward in MLKit normalised coords)
    final wristShoulderYRatio =
        (avgWristY - avgShoulderY) / shoulderWidth;

    // ── Signal 2: Elbow flare ratio ────────────────────────────────────────
    //
    // At TOP: elbows close to body, elbow span ≈ shoulder width
    //   elbowFlareRatio ≈ 0.0–0.2
    //
    // At BOTTOM: elbows flare out as arms bend
    //   elbowFlareRatio ≈ 0.3–0.8
    final elbowFlareRatio =
        (avgelbowxWidth - shoulderWidth) / shoulderWidth;

    // ── Plank deviation ────────────────────────────────────────────────────
    double plankDeviation = 0.0;
    final avgHipY = leftHip != null && rightHip != null &&
            leftHip.likelihood  >= _minConfidence &&
            rightHip.likelihood >= _minConfidence
        ? (leftHip.y + rightHip.y) / 2
        : null;

    if (avgHipY != null) {
      plankDeviation = (avgHipY - avgShoulderY) / shoulderWidth;
    }

    // ── Shoulder asymmetry ─────────────────────────────────────────────────
    final shoulderAsymmetry =
        (leftShoulder.y - rightShoulder.y).abs() / shoulderWidth;

    // ── Position validation ────────────────────────────────────────────────

    // 1. Shoulders are wide and level (person facing camera)
    final shouldersLevel = shoulderAsymmetry < 0.35;

    // 2. Wrists are below shoulders in Y — arms bearing weight on ground
    //    At least slightly positive means wrists are not above head
    final wristsGrounded = wristShoulderYRatio > -0.20;

    // 3. Wrists horizontally near shoulders — not flailed sideways
    final leftWristAligned =
        (leftWrist.x - leftShoulder.x).abs() < shoulderWidth * 0.70;
    final rightWristAligned =
        (rightWrist.x - rightShoulder.x).abs() < shoulderWidth * 0.70;

    // 4. Body is horizontal — hips near shoulder Y level (not standing)
    final bodyHorizontal = avgHipY == null ||
        (avgHipY - avgShoulderY).abs() < shoulderWidth * 1.4;

    // 5. No knee push-ups
    bool kneesOff = true;
    if (leftKnee  != null && rightKnee != null &&
        leftKnee.likelihood  >= _minConfidence &&
        rightKnee.likelihood >= _minConfidence &&
        avgHipY != null) {
      final avgKneeY     = (leftKnee.y + rightKnee.y) / 2;
      final kneeDrop     = avgKneeY - avgHipY;
      kneesOff = kneeDrop < shoulderWidth * 0.35;
    }

    // 6. Person is not standing — elbow flare should not be deeply negative
    //    (negative = elbows narrower than shoulders = standing/resting pose)
    final notStanding = elbowFlareRatio > -0.30;

    final isInPushupPosition = shouldersLevel   &&
                               wristsGrounded   &&
                               leftWristAligned &&
                               rightWristAligned &&
                               bodyHorizontal   &&
                               kneesOff         &&
                               notStanding;

    final confidence = [
      leftShoulder.likelihood,  rightShoulder.likelihood,
      leftElbow.likelihood,     rightElbow.likelihood,
      leftWrist.likelihood,     rightWrist.likelihood,
    ].reduce(min);

    return PushupMetrics(
      wristShoulderYRatio: wristShoulderYRatio,
      elbowFlareRatio:     elbowFlareRatio.clamp(-1.0, 3.0),
      plankDeviation:      plankDeviation,
      shoulderAsymmetry:   shoulderAsymmetry,
      isInPushupPosition:  isInPushupPosition,
      confidence:          confidence,
    );
  }
}