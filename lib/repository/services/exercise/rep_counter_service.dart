import 'package:ai_fitness_tracker/repository/model/exercise_type.dart';
import 'package:ai_fitness_tracker/repository/services/ml_services/jumping_jack_counter_service.dart';
import 'package:ai_fitness_tracker/repository/services/ml_services/pushup_rep_counter_service.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_counter_service.dart';
import '../ml_services/squat_rep_counter_service.dart';

class RepCounterService {
  late final Map<ExerciseType, BaseCounterService> _counters;
  late BaseCounterService _currentCounter;

  RepCounterService() {
    _counters = {
      ExerciseType.pushup: PushupRepCounterService(),
      ExerciseType.squat: SquatRepCounterService(),
      ExerciseType.jumpingJack: JumpingJackCounterService(),
    };
    _currentCounter = _counters[ExerciseType.pushup]!;
  }

  int get repCount => _currentCounter.repCount;

  void reset(ExerciseType type) {
    _currentCounter = _counters[type] ?? _counters[ExerciseType.squat]!;
    _currentCounter.reset();
  }

  bool isSetupValid(List<Pose> poses, ExerciseType type) {
    return (_counters[type] ?? _counters[ExerciseType.squat]!).isSetupValid(poses);
  }

  int processLandmarks(List<Pose> poses, ExerciseType type) {
    return (_counters[type] ?? _counters[ExerciseType.squat]!).processLandmarks(poses);
  }
}
