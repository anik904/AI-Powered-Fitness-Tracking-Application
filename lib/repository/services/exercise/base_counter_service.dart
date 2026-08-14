import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract class BaseCounterService {
  int get repCount;
  void reset();
  bool isSetupValid(List<Pose> poses);
  int processLandmarks(List<Pose> poses);
}
