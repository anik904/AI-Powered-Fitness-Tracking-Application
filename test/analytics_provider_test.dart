import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_fitness_tracker/repository/model/exercise_type.dart';
import 'package:ai_fitness_tracker/repository/model/workout_session.dart';
import 'package:ai_fitness_tracker/core/provider/workout_provider.dart';
import 'package:ai_fitness_tracker/core/provider/analytics_provider.dart';
import 'package:ai_fitness_tracker/repository/services/analytics/analytics_calculator.dart';

void main() {
  group('Analytics Provider & Calculator Tests', () {
    test('Calculates analytics data correctly with real workout sessions', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 0);
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final testWorkouts = [
        WorkoutSession(
          id: 1,
          exerciseType: ExerciseType.pushup,
          reps: 30,
          timestamp: today,
        ),
        WorkoutSession(
          id: 2,
          exerciseType: ExerciseType.squat,
          reps: 40,
          timestamp: yesterday,
        ),
        WorkoutSession(
          id: 3,
          exerciseType: ExerciseType.jumpingJack,
          reps: 50,
          timestamp: twoDaysAgo,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          workoutProvider.overrideWith(() => _MockWorkoutNotifier(testWorkouts)),
        ],
      );

      final analytics = container.read(analyticsDataProvider);

      expect(analytics.totalWorkouts, 3);
      expect(analytics.totalReps, 120);
      expect(analytics.currentStreak, 3);
      expect(analytics.challengeCompletedDays, 3);
      expect(analytics.challengeRemainingDays, 27);
      expect(analytics.challengePercentage, 10);

      // Distribution
      final pushupDist = analytics.distribution.firstWhere(
        (d) => d.exerciseType == ExerciseType.pushup,
      );
      expect(pushupDist.totalReps, 30);
      expect(pushupDist.percentage, closeTo(30 / 120, 0.01));
    });

    test('Handles empty workouts database gracefully without crashing', () {
      final container = ProviderContainer(
        overrides: [
          workoutProvider.overrideWith(() => _MockWorkoutNotifier([])),
        ],
      );

      final analytics = container.read(analyticsDataProvider);

      expect(analytics.totalWorkouts, 0);
      expect(analytics.totalReps, 0);
      expect(analytics.currentStreak, 0);
      expect(analytics.challengeCompletedDays, 0);
      expect(analytics.challengeRemainingDays, 30);
      expect(analytics.challengePercentage, 0);
      expect(analytics.recentWorkouts, isEmpty);

      for (final dist in analytics.distribution) {
        expect(dist.totalReps, 0);
        expect(dist.percentage, 0.0);
      }
    });

    test('Filter changing updates chart data and filtered workouts', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 0);
      final eightDaysAgo = today.subtract(const Duration(days: 8));

      final testWorkouts = [
        WorkoutSession(
          id: 1,
          exerciseType: ExerciseType.pushup,
          reps: 20,
          timestamp: today,
        ),
        WorkoutSession(
          id: 2,
          exerciseType: ExerciseType.squat,
          reps: 30,
          timestamp: eightDaysAgo,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          workoutProvider.overrideWith(() => _MockWorkoutNotifier(testWorkouts)),
        ],
      );

      // Default is 7 Days filter
      var analytics = container.read(analyticsDataProvider);
      expect(analytics.totalWorkouts, 1);
      expect(analytics.totalReps, 20);

      // Change filter to 30 Days
      container.read(analyticsFilterProvider.notifier).setFilter(AnalyticsTimeFilter.thirtyDays);
      analytics = container.read(analyticsDataProvider);
      expect(analytics.totalWorkouts, 2);
      expect(analytics.totalReps, 50);
      expect(analytics.chartBars.length, 4);
    });

    test('AnalyticsCalculator pure computation works independently', () {
      final now = DateTime(2026, 8, 16, 12, 0);
      final today = DateTime(2026, 8, 16, 8, 0);
      final sessions = [
        WorkoutSession(
          id: 1,
          exerciseType: ExerciseType.pushup,
          reps: 50,
          timestamp: today,
        ),
      ];

      final result = AnalyticsCalculator.compute(
        allWorkouts: sessions,
        filter: AnalyticsTimeFilter.sevenDays,
        now: now,
      );

      expect(result.totalWorkouts, 1);
      expect(result.totalReps, 50);
      expect(result.currentStreak, 1);
    });
  });
}

class _MockWorkoutNotifier extends WorkoutNotifier {
  final List<WorkoutSession> _initialWorkouts;
  _MockWorkoutNotifier(this._initialWorkouts);

  @override
  List<WorkoutSession> build() {
    return _initialWorkouts;
  }
}
