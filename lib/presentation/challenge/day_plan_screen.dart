import 'package:ai_fitness_tracker/repository/model/exercise_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/provider/challenge_provider.dart';
import '../../core/provider/exercise_goal_provider.dart';
import '../../core/provider/workout_provider.dart';
import '../exercise/exercise_instruction_screen.dart';

import '../../widgets/exercise_icon_widget.dart';

class DayPlanScreen extends ConsumerWidget {
  final int day;
  final bool isCompleted;

  const DayPlanScreen({super.key, required this.day, this.isCompleted = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final goals = ref.watch(exerciseGoalProvider);
    final challengeState = ref.watch(challengeProvider);
    final allWorkouts = ref.watch(workoutProvider);
    
    final targetDate = challengeState.startDate?.add(Duration(days: day - 1)) ?? DateTime.now();
    final dayWorkouts = allWorkouts.where((w) => 
      w.timestamp.year == targetDate.year &&
      w.timestamp.month == targetDate.month &&
      w.timestamp.day == targetDate.day &&
      (challengeState.startDate == null || !w.timestamp.isBefore(challengeState.startDate!))
    ).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Day $day', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Plan',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (goals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('No workout goals configured.'),
              )
            else
              ...goals.map((goal) {
                final typeWorkouts = dayWorkouts.where(
                  (w) => w.exerciseType == goal.cardData.routeType,
                );
                final completed = typeWorkouts.fold(0, (sum, w) => sum + w.reps);
                final isDone = completed >= goal.target;

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseInstructionScreen(
                          exerciseType: goal.cardData.routeType,
                          sessionOption: goal.matchOption,
                        ),
                      ),
                    );
                  },
                  child: _buildExerciseItem(
                    context,
                    goal.cardData.routeType,
                    goal.cardData.title,
                    goal.target,
                    completed,
                    isDone,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(
    BuildContext context,
    ExerciseType exerciseType,
    String name,
    int target,
    int completed,
    bool isDone,
  ) {
    final theme = Theme.of(context);
    final progress = target > 0 ? (completed / target).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDone ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExerciseIconWidget(
              exerciseType: exerciseType,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completed / $target reps',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!isDone) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                    minHeight: 4,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isDone)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Done',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          else
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 14,
          ),
        ],
      ),
    );
  }
}
