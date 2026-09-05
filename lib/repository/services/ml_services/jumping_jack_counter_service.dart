import 'package:ai_fitness_tracker/repository/services/exercise/base_counter_service.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'jumping_jack_validation_service.dart';

enum JumpingJackPhase { closed, open }

class JumpingJackCounterService extends BaseCounterService {
  int _repCount = 0;

  JumpingJackPhase _phase = JumpingJackPhase.closed;

  final JumpingJackValidationService _validationService =
      JumpingJackValidationService();

  @override
  int get repCount => _repCount;

  @override
  void reset() {
    _repCount = 0;
    _phase = JumpingJackPhase.closed;
  }

  @override
  bool isSetupValid(List<Pose> poses) {
    if (poses.isEmpty) return false;
    return _validationService.isValidJumpingJack(poses.first);
  }

  @override
  int processLandmarks(List<Pose> poses) {
    if (poses.isEmpty) return _repCount;

    final pose = poses.first;
    final landmarks = pose.landmarks;

    final leftWrist     = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist    = landmarks[PoseLandmarkType.rightWrist];
    final leftAnkle     = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle    = landmarks[PoseLandmarkType.rightAnkle];
    final leftHip       = landmarks[PoseLandmarkType.leftHip];
    final rightHip      = landmarks[PoseLandmarkType.rightHip];
    final leftShoulder  = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow     = landmarks[PoseLandmarkType.leftElbow];
    final rightElbow    = landmarks[PoseLandmarkType.rightElbow];

    if ([
      leftWrist, rightWrist, leftAnkle, rightAnkle,
      leftHip, rightHip, leftShoulder, rightShoulder,
      leftElbow, rightElbow,
    ].any((l) => l == null)) {
      return _repCount;
    }

    final hipWidth      = (leftHip!.x - rightHip!.x).abs();
    final shoulderWidth = (leftShoulder!.x - rightShoulder!.x).abs();
    final feetSpread    = (leftAnkle!.x - rightAnkle!.x).abs();

    // Arms: use shoulder Y as reference
    // In OPEN position wrists go above shoulders.
    // In CLOSED position wrists stay below shoulders.
    final avgShoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final armsUp   = leftWrist!.y  < avgShoulderY &&
                     rightWrist!.y < avgShoulderY;
    final armsDown = leftWrist.y   > avgShoulderY &&
                     rightWrist!.y  > avgShoulderY;

    // Feet: OPEN = spread wider than shoulders, CLOSED = narrower than hips
    final feetOpen   = feetSpread > shoulderWidth * 0.85;
    final feetClosed = feetSpread < hipWidth * 1.1;

    // Both conditions must be true simultaneously for a phase to register
    final isOpenPose   = armsUp   && feetOpen;
    final isClosedPose = armsDown && feetClosed;

    switch (_phase) {
      case JumpingJackPhase.closed:
        if (isOpenPose) {
          _repCount++;
          _phase = JumpingJackPhase.open;
        }
        break;

      case JumpingJackPhase.open:
        if (isClosedPose) {
          _phase = JumpingJackPhase.closed;
        }
        break;
    }

    return _repCount;
  }
}