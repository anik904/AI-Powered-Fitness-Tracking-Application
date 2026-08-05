import 'package:flutter/material.dart';

class DayPlanScreen extends StatelessWidget {
  final int day;
  final bool isCompleted;

  const DayPlanScreen({super.key, required this.day, this.isCompleted = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            _buildExerciseItem(context, 'Push-ups', 10, isCompleted ? 10 : 0, isCompleted),
            _buildExerciseItem(context, 'Squats', 15, isCompleted ? 15 : 0, isCompleted),
            _buildExerciseItem(context, 'Jumping Jacks', 20, isCompleted ? 20 : 0, isCompleted),
            const SizedBox(height: 32),
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Workout started!')),
                    );
                  },
                  child: const Text('Start Workout'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(BuildContext context, String name, int target, int completed, bool isDone) {
    final theme = Theme.of(context);
    final progress = target > 0 ? completed / target : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? theme.colorScheme.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDone ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDone ? Icons.check_circle : Icons.fitness_center,
              color: isDone ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completed / $target reps',
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    if (!isDone)
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                if (!isDone) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                    minHeight: 4,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
