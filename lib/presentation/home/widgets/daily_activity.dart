import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_card.dart';
import '../../../core/provider/exercise_goal_provider.dart';
import '../../../core/provider/workout_provider.dart';
import '../../../repository/model/exercise_type.dart';
import '../../../widgets/exercise_icon_widget.dart';

class DailyActivity extends ConsumerWidget {
  const DailyActivity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(exerciseGoalProvider);
    final todayWorkouts = ref.watch(todayWorkoutProvider);

    int totalProgressPercentage = 0;
    List<Widget> statsList = [];

    if (goals.isNotEmpty) {
      double totalPercentageSum = 0;

      for (int i = 0; i < goals.length; i++) {
        final goal = goals[i];
        // Calculate progress for this goal
        final typeWorkouts = todayWorkouts.where(
          (w) => w.exerciseType == goal.cardData.routeType,
        );

        int completedAmount = typeWorkouts.fold(0, (sum, w) => sum + w.reps);

        double percentage = goal.target > 0
            ? completedAmount / goal.target
            : 0.0;
        if (percentage > 1.0) percentage = 1.0;
        totalPercentageSum += percentage;

        statsList.add(
          _ActivityStat(
            exerciseType: goal.cardData.routeType,
            title: goal.cardData.title,
            value: '$completedAmount/${goal.target}',
          ),
        );
        if (i < goals.length - 1) {
          statsList.add(const SizedBox(height: 12));
        }
      }

      totalProgressPercentage = ((totalPercentageSum / goals.length) * 100)
          .toInt();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily Activity', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        CustomCard(
          color: AppTheme.accentColor.withValues(alpha: 0.4),
          padding: const EdgeInsets.all(20),
          margin: EdgeInsets.zero,
          child: Row(
            children: [
              // Progress Circle
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: totalProgressPercentage / 100,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppTheme.background,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.accentColor,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$totalProgressPercentage%',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Goal',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Stats List
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: statsList.isNotEmpty
                      ? statsList
                      : [
                          const Text(
                            "No goals set",
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityStat extends StatelessWidget {
  final ExerciseType exerciseType;
  final String title;
  final String value;

  const _ActivityStat({
    required this.exerciseType,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExerciseIconWidget(exerciseType: exerciseType, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
