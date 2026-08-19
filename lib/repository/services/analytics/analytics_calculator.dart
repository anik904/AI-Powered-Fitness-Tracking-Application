import '../../model/analytics_models.dart';
import '../../model/exercise_type.dart';
import '../../model/workout_session.dart';

class AnalyticsCalculator {
  static const List<String> _weekdayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  static AnalyticsData compute({
    required List<WorkoutSession> allWorkouts,
    required AnalyticsTimeFilter filter,
    required bool isChallengeActive,
    DateTime? challengeStartDate,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final todayStart = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    );

    final filteredWorkouts = filterWorkouts(allWorkouts, filter, todayStart);
    final totalWorkouts = filteredWorkouts.length;
    final totalReps = filteredWorkouts.fold<int>(0, (sum, w) => sum + w.reps);

    final uniqueWorkoutDates = _getUniqueDates(allWorkouts);
    final currentStreak = calculateStreak(uniqueWorkoutDates, todayStart);
    final (challengeCompleted, challengeRemaining, challengePercentage, challengeStreak) =
        calculateChallengeProgress(
      allWorkouts: allWorkouts,
      isChallengeActive: isChallengeActive,
      challengeStartDate: challengeStartDate,
      todayStart: todayStart,
    );
    
    int challengeCurrentDayIndex = 1;
    if (isChallengeActive && challengeStartDate != null) {
      final start = DateTime(
        challengeStartDate.year,
        challengeStartDate.month,
        challengeStartDate.day,
      );
      final calendarDaysPassed = todayStart.difference(start).inDays;
      final maxAllowedDay = (calendarDaysPassed + 1).clamp(1, 30);
      final targetDay = (challengeCompleted + 1).clamp(1, 30);
      challengeCurrentDayIndex = targetDay > maxAllowedDay ? maxAllowedDay : targetDay;
    }

    final chartBars = calculateChartBars(
      allWorkouts: allWorkouts,
      filter: filter,
      todayStart: todayStart,
      now: currentTime,
    );

    final distribution = calculateDistribution(
      filteredWorkouts: filteredWorkouts,
      totalReps: totalReps,
    );

    final recentWorkouts = allWorkouts.take(10).toList();

    return AnalyticsData(
      totalWorkouts: totalWorkouts,
      totalReps: totalReps,
      currentStreak: currentStreak,
      challengeStreak: challengeStreak,
      isChallengeActive: isChallengeActive,
      challengeStartDate: challengeStartDate,
      challengeCompletedDays: challengeCompleted,
      challengeRemainingDays: challengeRemaining,
      challengePercentage: challengePercentage,
      challengeCurrentDayIndex: challengeCurrentDayIndex,
      chartBars: chartBars,
      distribution: distribution,
      recentWorkouts: recentWorkouts,
      currentFilter: filter,
    );
  }

  static List<WorkoutSession> filterWorkouts(
    List<WorkoutSession> workouts,
    AnalyticsTimeFilter filter,
    DateTime todayStart,
  ) {
    switch (filter) {
      case AnalyticsTimeFilter.sevenDays:
        final sevenDaysAgo = todayStart.subtract(const Duration(days: 6));
        return workouts.where((w) => !w.timestamp.isBefore(sevenDaysAgo)).toList();
      case AnalyticsTimeFilter.thirtyDays:
        final thirtyDaysAgo = todayStart.subtract(const Duration(days: 29));
        return workouts.where((w) => !w.timestamp.isBefore(thirtyDaysAgo)).toList();
      case AnalyticsTimeFilter.allTime:
        return workouts;
    }
  }

  static Set<String> _getUniqueDates(List<WorkoutSession> workouts) {
    final dates = <String>{};
    for (final w in workouts) {
      dates.add(_formatDateKey(w.timestamp));
    }
    return dates;
  }

  static String _formatDateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static int calculateStreak(Set<String> uniqueDates, DateTime todayStart) {
    final todayKey = _formatDateKey(todayStart);
    final yesterdayKey =
        _formatDateKey(todayStart.subtract(const Duration(days: 1)));

    DateTime checkDate;
    if (uniqueDates.contains(todayKey)) {
      checkDate = todayStart;
    } else if (uniqueDates.contains(yesterdayKey)) {
      checkDate = todayStart.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    int streak = 0;
    while (uniqueDates.contains(_formatDateKey(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static (int completed, int remaining, int percentage, int challengeStreak)
      calculateChallengeProgress({
    required List<WorkoutSession> allWorkouts,
    required bool isChallengeActive,
    DateTime? challengeStartDate,
    required DateTime todayStart,
  }) {
    if (!isChallengeActive || challengeStartDate == null) {
      return (0, 30, 0, 0);
    }

    final challengeWorkouts = allWorkouts.where((w) => !w.timestamp.isBefore(challengeStartDate)).toList();
    final uniqueDates = _getUniqueDates(challengeWorkouts);
    final challengeStreak = calculateStreak(uniqueDates, todayStart);

    final completedDays = uniqueDates.length.clamp(0, 30);
    final remainingDays = (30 - completedDays).clamp(0, 30);
    final percentage = ((completedDays / 30) * 100).round();
    
    return (completedDays, remainingDays, percentage, challengeStreak);
  }

  static List<ChartBarData> calculateChartBars({
    required List<WorkoutSession> allWorkouts,
    required AnalyticsTimeFilter filter,
    required DateTime todayStart,
    required DateTime now,
  }) {
    switch (filter) {
      case AnalyticsTimeFilter.sevenDays:
        return _buildSevenDaysChart(allWorkouts, todayStart);
      case AnalyticsTimeFilter.thirtyDays:
        return _buildThirtyDaysChart(allWorkouts, todayStart);
      case AnalyticsTimeFilter.allTime:
        return _buildAllTimeChart(allWorkouts, now);
    }
  }

  static List<ChartBarData> _buildSevenDaysChart(
    List<WorkoutSession> allWorkouts,
    DateTime todayStart,
  ) {
    final dailyReps = <int>[];
    for (int i = 6; i >= 0; i--) {
      final targetDay = todayStart.subtract(Duration(days: i));
      final repsForDay = allWorkouts
          .where((w) =>
              w.timestamp.year == targetDay.year &&
              w.timestamp.month == targetDay.month &&
              w.timestamp.day == targetDay.day)
          .fold<int>(0, (sum, w) => sum + w.reps);
      dailyReps.add(repsForDay);
    }

    final maxRep = dailyReps.fold<int>(0, (max, r) => r > max ? r : max);
    final chartBars = <ChartBarData>[];

    for (int i = 6; i >= 0; i--) {
      final targetDay = todayStart.subtract(Duration(days: i));
      final reps = dailyReps[6 - i];
      final ratio = maxRep > 0 ? (reps / maxRep).clamp(0.0, 1.0) : 0.0;
      final label = _weekdayNames[targetDay.weekday - 1];

      chartBars.add(ChartBarData(
        label: label,
        reps: reps,
        ratio: ratio,
        isToday: i == 0,
      ));
    }
    return chartBars;
  }

  static List<ChartBarData> _buildThirtyDaysChart(
    List<WorkoutSession> allWorkouts,
    DateTime todayStart,
  ) {
    final weeklyReps = <int>[0, 0, 0, 0];
    for (int i = 0; i < 28; i++) {
      final targetDay = todayStart.subtract(Duration(days: 27 - i));
      final weekIndex = (i ~/ 7).clamp(0, 3);
      final repsForDay = allWorkouts
          .where((w) =>
              w.timestamp.year == targetDay.year &&
              w.timestamp.month == targetDay.month &&
              w.timestamp.day == targetDay.day)
          .fold<int>(0, (sum, w) => sum + w.reps);
      weeklyReps[weekIndex] += repsForDay;
    }

    final maxRep = weeklyReps.fold<int>(0, (max, r) => r > max ? r : max);
    const labels = ['W-3', 'W-2', 'W-1', 'This Wk'];
    final chartBars = <ChartBarData>[];

    for (int i = 0; i < 4; i++) {
      final reps = weeklyReps[i];
      final ratio = maxRep > 0 ? (reps / maxRep).clamp(0.0, 1.0) : 0.0;
      chartBars.add(ChartBarData(
        label: labels[i],
        reps: reps,
        ratio: ratio,
        isToday: i == 3,
      ));
    }
    return chartBars;
  }

  static List<ChartBarData> _buildAllTimeChart(
    List<WorkoutSession> allWorkouts,
    DateTime now,
  ) {
    final monthlyReps = <int>[];
    final monthLabels = <String>[];

    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final repsForMonth = allWorkouts
          .where((w) =>
              w.timestamp.year == monthDate.year &&
              w.timestamp.month == monthDate.month)
          .fold<int>(0, (sum, w) => sum + w.reps);
      monthlyReps.add(repsForMonth);
      monthLabels.add(_monthNames[monthDate.month - 1]);
    }

    final maxRep = monthlyReps.fold<int>(0, (max, r) => r > max ? r : max);
    final chartBars = <ChartBarData>[];

    for (int i = 0; i < 6; i++) {
      final reps = monthlyReps[i];
      final ratio = maxRep > 0 ? (reps / maxRep).clamp(0.0, 1.0) : 0.0;
      chartBars.add(ChartBarData(
        label: monthLabels[i],
        reps: reps,
        ratio: ratio,
        isToday: i == 5,
      ));
    }
    return chartBars;
  }

  static List<ExerciseDistributionData> calculateDistribution({
    required List<WorkoutSession> filteredWorkouts,
    required int totalReps,
  }) {
    return ExerciseType.values.map((type) {
      final reps = filteredWorkouts
          .where((w) => w.exerciseType == type)
          .fold<int>(0, (sum, w) => sum + w.reps);
      final percentage = totalReps > 0 ? (reps / totalReps) : 0.0;
      return ExerciseDistributionData(
        exerciseType: type,
        totalReps: reps,
        percentage: percentage,
      );
    }).toList();
  }
}
