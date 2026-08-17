import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class JumpingJackValidationService {
  bool isValidJumpingJack(Pose pose) {
    final landmarks = pose.landmarks;

    final leftWrist     = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist    = landmarks[PoseLandmarkType.rightWrist];
    final leftAnkle     = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle    = landmarks[PoseLandmarkType.rightAnkle];
    final leftHip       = landmarks[PoseLandmarkType.leftHip];
    final rightHip      = landmarks[PoseLandmarkType.rightHip];
    final leftShoulder  = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    if ([
      leftWrist, rightWrist, leftAnkle, rightAnkle,
      leftHip, rightHip, leftShoulder, rightShoulder,
    ].any((l) => l == null)) {
      return false;
    }

    // Person must be standing — hips above ankles
    final avgHipY    = (leftHip!.y + rightHip!.y) / 2;
    final avgAnkleY  = (leftAnkle!.y + rightAnkle!.y) / 2;
    final isStanding = avgAnkleY > avgHipY; // y increases downward in MLKit

    // Full body must be in frame — basic sanity check via spread of key points
    final bodyHeight = avgAnkleY - (leftShoulder!.y + rightShoulder!.y) / 2;
    final isInFrame  = bodyHeight > 0.2; // at least 20% of normalised frame

    return isStanding && isInFrame;
  }
}