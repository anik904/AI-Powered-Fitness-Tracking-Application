import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/provider/exercise_goal_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../repository/model/exercise_type.dart';
import '../../../repository/model/exercise_workout_data.dart';
import '../../../repository/model/workout_match_option.dart';
import '../../exercise/exercise_instruction_screen.dart';

class QuickStartSection extends ConsumerWidget {
  const QuickStartSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Start', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _buildExerciseCard(
          title: 'Push-ups',
          icon: Icons.fitness_center,
          onTap: () => _startWorkout(context, ref, ExerciseType.pushup),
        ),
        const SizedBox(height: 8),
        _buildExerciseCard(
          title: 'Squats',
          icon: Icons.accessibility_new,
          onTap: () => _startWorkout(context, ref, ExerciseType.squat),
        ),
        const SizedBox(height: 8),
        _buildExerciseCard(
          title: 'Jumping Jacks',
          icon: Icons.directions_run,
          onTap: () => _startWorkout(context, ref, ExerciseType.jumpingJack),
        ),
      ],
    );
  }

  void _startWorkout(
    BuildContext context,
    WidgetRef ref,
    ExerciseType exerciseType,
  ) {
    final fallbackOption =
        exerciseMatchOptions[exerciseType]?.first ??
        const WorkoutMatchOption(reps: 20, minutes: 0, unit: 'Reps');
    final goals = ref.read(exerciseGoalProvider);
    final goal = goals.firstWhere(
      (g) => g.cardData.routeType == exerciseType,
      orElse: () => ExerciseGoal(
        cardData: ExerciseCardData(
          title: exerciseType.displayName,
          badgeColor: Colors.blue,
          iconBg: Colors.blue,
          icon: Icons.fitness_center,
          routeType: exerciseType,
        ),
        target: fallbackOption.reps,
        unit: fallbackOption.unit,
        matchOption: fallbackOption,
      ),
    );

    final sessionOption = WorkoutMatchOption(
      reps: goal.target,
      minutes: 0,
      unit: goal.unit,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseInstructionScreen(
          exerciseType: exerciseType,
          sessionOption: sessionOption,
        ),
      ),
    );
  }

  Widget _buildExerciseCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.accentColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
