import 'exercise_type.dart';
import 'workout_session.dart';

enum AnalyticsTimeFilter {
  sevenDays('7 Days'),
  thirtyDays('30 Days'),
  allTime('All Time');

  final String label;
  const AnalyticsTimeFilter(this.label);
}

class ChartBarData {
  final String label;
  final int reps;
  final double ratio;
  final bool isToday;

  const ChartBarData({
    required this.label,
    required this.reps,
    required this.ratio,
    required this.isToday,
  });
}

class ExerciseDistributionData {
  final ExerciseType exerciseType;
  final int totalReps;
  final double percentage; // 0.0 to 1.0

  const ExerciseDistributionData({
    required this.exerciseType,
    required this.totalReps,
    required this.percentage,
  });
}

class AnalyticsData {
  final int totalWorkouts;
  final int totalReps;
  final int currentStreak;
  final int challengeCompletedDays;
  final int challengeRemainingDays;
  final int challengePercentage;
  final List<ChartBarData> chartBars;
  final List<ExerciseDistributionData> distribution;
  final List<WorkoutSession> recentWorkouts;
  final AnalyticsTimeFilter currentFilter;

  const AnalyticsData({
    required this.totalWorkouts,
    required this.totalReps,
    required this.currentStreak,
    required this.challengeCompletedDays,
    required this.challengeRemainingDays,
    required this.challengePercentage,
    required this.chartBars,
    required this.distribution,
    required this.recentWorkouts,
    required this.currentFilter,
  });
}
