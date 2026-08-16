import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'section_container.dart';
import '../../../widgets/custom_card.dart';
import '../../../core/provider/analytics_provider.dart';
import '../../../repository/model/exercise_type.dart';

class RecentActivity extends ConsumerWidget {
  const RecentActivity({super.key});

  IconData _getExerciseIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.pushup:
        return Icons.fitness_center;
      case ExerciseType.squat:
        return Icons.accessibility_new;
      case ExerciseType.jumpingJack:
        return Icons.directions_run;
    }
  }

  String _formatDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (workoutDate == today) {
      return 'Today';
    } else if (workoutDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      const monthNames = [
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
        'Dec',
      ];
      if (timestamp.year == now.year) {
        return '${monthNames[timestamp.month - 1]} ${timestamp.day}';
      }
      return '${monthNames[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsDataProvider);
    final workouts = analytics.recentWorkouts;

    return SectionContainer(
      title: 'Recent Activity',
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: EdgeInsets.zero,
        child: workouts.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 40,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No workout activity yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  for (int i = 0; i < workouts.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: _buildActivityItem(
                        context,
                        date: _formatDate(workouts[i].timestamp),
                        exercise: workouts[i].exerciseType.displayName,
                        exerciseType: workouts[i].exerciseType,
                        reps: '${workouts[i].reps} Reps',
                      ),
                    ),
                    if (i < workouts.length - 1)
                      Divider(
                        height: 1,
                        thickness: 0.6,
                        color: Colors.grey.withValues(alpha: 0.12),
                      ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String date,
    required String exercise,
    required ExerciseType exerciseType,
    required String reps,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getExerciseIcon(exerciseType),
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          reps,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
