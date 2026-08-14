import 'dart:async';

import 'package:ai_fitness_tracker/repository/model/exercise_type.dart';
import 'package:ai_fitness_tracker/repository/model/rep_state.dart';
import 'package:ai_fitness_tracker/repository/model/exercise_workout_data.dart';
import 'package:ai_fitness_tracker/repository/model/workout_match_option.dart';
import 'package:ai_fitness_tracker/repository/services/exercise/pose_detector_service.dart';
import 'package:ai_fitness_tracker/repository/services/exercise/rep_counter_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';


class ExerciseState {
  final int repCount;
  final ExerciseType exerciseType;
  final RepState repState;
  final bool isBodyDetected;
  final bool isSetupValid;
  final bool isLoading;
  final List<Pose> currentPoses;
  final DateTime? startTime;
  final WorkoutMatchOption? sessionOption;

  const ExerciseState({
    this.repCount = 0,
    this.exerciseType = ExerciseType.pushup,
    this.repState = RepState.up,
    this.isBodyDetected = false,
    this.isSetupValid = false,
    this.isLoading = false,
    this.currentPoses = const [],
    this.startTime,
    this.sessionOption,
  });

  ExerciseState copyWith({
    int? repCount,
    ExerciseType? exerciseType,
    RepState? repState,
    bool? isBodyDetected,
    bool? isSetupValid,
    bool? isLoading,
    List<Pose>? currentPoses,
    DateTime? startTime,
    WorkoutMatchOption? sessionOption,
  }) {
    return ExerciseState(
      repCount: repCount ?? this.repCount,
      exerciseType: exerciseType ?? this.exerciseType,
      repState: repState ?? this.repState,
      isBodyDetected: isBodyDetected ?? this.isBodyDetected,
      isSetupValid: isSetupValid ?? this.isSetupValid,
      isLoading: isLoading ?? this.isLoading,
      currentPoses: currentPoses ?? this.currentPoses,
      startTime: startTime ?? this.startTime,
      sessionOption: sessionOption ?? this.sessionOption,
    );
  }

  bool get isComplete {
    final opt = sessionOption;
    if (opt == null) return false;
    return repCount >= opt.reps;
  }

  double get progress {
    final opt = sessionOption;
    if (opt == null || opt.reps == 0) return 0.0;
    return (repCount / opt.reps).clamp(0.0, 1.0);
  }
}

class ExerciseNotifier extends Notifier<ExerciseState> {
  static const Duration _setupValidOnDelay = Duration(milliseconds: 250);
  static const Duration _setupValidOffDelay = Duration(milliseconds: 650);
  static const Duration _bodyDetectedOnDelay = Duration(milliseconds: 140);
  static const Duration _bodyDetectedOffDelay = Duration(milliseconds: 500);

  final PoseDetectorService _poseDetector = PoseDetectorService();
  final RepCounterService _repCounter = RepCounterService();
  Timer? _secondTicker;
  bool _isPlankHolding = false;
  bool? _pendingBodyValue;
  DateTime? _pendingBodySince;
  bool? _pendingSetupValue;
  DateTime? _pendingSetupSince;

  @override
  ExerciseState build() {
    ref.onDispose(() {
      _poseDetector.dispose();
      _secondTicker?.cancel();
    });
    return const ExerciseState();
  }

  void initialize(ExerciseType type, {WorkoutMatchOption? sessionOption}) {
    _poseDetector.initialize();
    _repCounter.reset(type);
    _resetStabilityCounters();
    final options = exerciseMatchOptions[type];
    final selectedOption =
        sessionOption ??
        (options != null && options.isNotEmpty ? options.first : null);
    state = ExerciseState(
      exerciseType: type,
      startTime: DateTime.now(),
      sessionOption: selectedOption,
    );
    // If this is a time-based exercise (seconds), start the per-second ticker
    _ensureTicker();
  }

  void updateSessionOption(WorkoutMatchOption option) {
    state = state.copyWith(
      sessionOption: option,
      repCount: 0,
      startTime: DateTime.now(),
    );
    _repCounter.reset(state.exerciseType);
    _ensureTicker();
  }

  Future<void> processFrame(
    CameraImage image,
    InputImageRotation rotation,
  ) async {
    final poses = await _poseDetector.processFrame(image, rotation);
    if (poses == null) return;

    final rawBodyDetected = poses.isNotEmpty;
    final rawSetupValid =
        rawBodyDetected && _repCounter.isSetupValid(poses, state.exerciseType);

    final isBodyDetected = _applyBodyDetectionStability(rawBodyDetected);
    final isSetupValid = _applySetupStability(rawSetupValid);
    final shouldCountReps = isSetupValid;

    int newRepCount = state.repCount;
    // For time-based exercises (unit == 'sec'), we use plank validation
    // and a per-second ticker to increment elapsed seconds.
      newRepCount = shouldCountReps
          ? _repCounter.processLandmarks(poses, state.exerciseType)
          : state.repCount;
 

    state = state.copyWith(
      repCount: newRepCount,
      // RepState logic: if not counting, set to up; otherwise, keep previous or infer from rep count change
      repState: RepState.up,
      isBodyDetected: isBodyDetected,
      isSetupValid: isSetupValid,
      currentPoses: poses,
      // sessionOption remains unchanged
    );
  }

  void _ensureTicker() {
    _secondTicker?.cancel();
    _secondTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final opt = state.sessionOption;
      if (opt == null) return;
      if (opt.unit.toLowerCase() != 'sec') return;
      final total = opt.reps;
      if (_isPlankHolding && state.repCount < total) {
        state = state.copyWith(repCount: state.repCount + 1);
      }
    });
  }

  void reset() {
    _repCounter.reset(state.exerciseType);
    _resetStabilityCounters();
    state = state.copyWith(
      repCount: 0,
      repState: RepState.up,
      isBodyDetected: false,
      isSetupValid: false,
      currentPoses: [],
    );
    _isPlankHolding = false;
  }

  bool _applySetupStability(bool rawSetupValid) {
    final now = DateTime.now();
    if (_pendingSetupValue != rawSetupValid) {
      _pendingSetupValue = rawSetupValid;
      _pendingSetupSince = now;
    }

    if (rawSetupValid == state.isSetupValid) return state.isSetupValid;

    final stableFor = now.difference(_pendingSetupSince ?? now);
    final requiredDelay = rawSetupValid
        ? _setupValidOnDelay
        : _setupValidOffDelay;

    return stableFor >= requiredDelay ? rawSetupValid : state.isSetupValid;
  }

  bool _applyBodyDetectionStability(bool rawBodyDetected) {
    final now = DateTime.now();
    if (_pendingBodyValue != rawBodyDetected) {
      _pendingBodyValue = rawBodyDetected;
      _pendingBodySince = now;
    }

    if (rawBodyDetected == state.isBodyDetected) return state.isBodyDetected;

    final stableFor = now.difference(_pendingBodySince ?? now);
    final requiredDelay = rawBodyDetected
        ? _bodyDetectedOnDelay
        : _bodyDetectedOffDelay;

    return stableFor >= requiredDelay ? rawBodyDetected : state.isBodyDetected;
  }

  void _resetStabilityCounters() {
    _pendingBodyValue = null;
    _pendingBodySince = null;
    _pendingSetupValue = null;
    _pendingSetupSince = null;
  }
}

final exerciseProvider = NotifierProvider<ExerciseNotifier, ExerciseState>(() {
  return ExerciseNotifier();
});
