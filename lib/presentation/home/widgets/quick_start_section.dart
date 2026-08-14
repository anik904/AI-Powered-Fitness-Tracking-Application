import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../repository/model/exercise_type.dart';
import '../../../repository/model/exercise_workout_data.dart';
import '../../exercise/exercise_instruction_screen.dart';

class QuickStartSection extends StatelessWidget {
  const QuickStartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Start',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildExerciseCard(
          title: 'Push-ups',
          icon: Icons.fitness_center,
          onTap: () => _showComingSoon(context, 'Push-ups'),
        ),
        const SizedBox(height: 12),
        _buildExerciseCard(
          title: 'Squats',
          icon: Icons.accessibility_new,
          onTap: () => _startSquatWorkout(context),
        ),
        const SizedBox(height: 12),
        _buildExerciseCard(
          title: 'Jumping Jacks',
          icon: Icons.directions_run,
          onTap: () => _showComingSoon(context, 'Jumping Jacks'),
        ),
      ],
    );
  }

  void _startSquatWorkout(BuildContext context) {
    final sessionOption = exerciseMatchOptions[ExerciseType.squat]!.firstWhere(
      (option) => option.reps == 20,
      orElse: () => exerciseMatchOptions[ExerciseType.squat]!.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseInstructionScreen(
          exerciseType: ExerciseType.squat,
          sessionOption: sessionOption,
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String exerciseName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$exerciseName is not wired yet.')),
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
          border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
