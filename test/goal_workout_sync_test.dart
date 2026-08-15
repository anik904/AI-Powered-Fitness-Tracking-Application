import 'package:flutter_test/flutter_test.dart';
import 'package:ai_fitness_tracker/repository/model/exercise_type.dart';
import 'package:ai_fitness_tracker/repository/model/workout_session.dart';
import 'package:ai_fitness_tracker/repository/model/workout_match_option.dart';
import 'package:ai_fitness_tracker/core/provider/exercise_provider.dart';

void main() {
  group('Exercise Goal & Reps Sync Tests', () {
    test('WorkoutSession toMap and fromMap serialization', () {
      final now = DateTime.now();
      final session = WorkoutSession(
        id: 1,
        exerciseType: ExerciseType.pushup,
        reps: 25,
        timestamp: now,
      );

      final map = session.toMap();
      expect(map['id'], 1);
      expect(map['exerciseType'], 'pushup');
      expect(map['reps'], 25);
      expect(map['timestamp'], now.toIso8601String());

      final parsed = WorkoutSession.fromMap(map);
      expect(parsed.id, 1);
      expect(parsed.exerciseType, ExerciseType.pushup);
      expect(parsed.reps, 25);
    });

    test('ExerciseState progress and isComplete calculation with goal', () {
      const option = WorkoutMatchOption(reps: 45, minutes: 5, unit: 'Reps');
      const state = ExerciseState(
        repCount: 15,
        exerciseType: ExerciseType.pushup,
        sessionOption: option,
      );

      expect(state.isComplete, false);
      expect(state.progress, closeTo(15 / 45, 0.001));

      final completedState = state.copyWith(repCount: 45);
      expect(completedState.isComplete, true);
      expect(completedState.progress, 1.0);
    });
  });
}

