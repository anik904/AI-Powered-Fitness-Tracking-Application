import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/provider/workout_provider.dart';
import '../../../repository/model/exercise_type.dart';

import '../../../widgets/exercise_icon_widget.dart';

class RecentWorkoutSection extends ConsumerWidget {
  const RecentWorkoutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutProvider);

    if (workouts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Workouts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.textSecondary.withValues(alpha: 0.1),
              ),
            ),
            child: const Center(
              child: Text(
                'No recent workouts',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ),
          ),
        ],
      );
    }

    final recentWorkouts = workouts.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Workouts', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...recentWorkouts.map((workout) {
          final timeStr = _formatTimestamp(workout.timestamp);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.textSecondary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ExerciseIconWidget(
                      exerciseType: workout.exerciseType,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.exerciseType.displayName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${workout.reps} reps',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day) {
      return "Today, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    } else {
      return "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
    }
  }
}
