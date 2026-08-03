import 'package:flutter/material.dart';
import 'section_container.dart';

import '../../../core/widgets/custom_card.dart';

class ExerciseStats extends StatelessWidget {
  const ExerciseStats({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Exercise Statistics',
      child: SizedBox(
        height: 150,
        child: ListView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          children: [
            _buildStatDetailCard(context, 'Push-ups', '520 Reps', 'Best: 45 reps', 'Last: Today'),
            const SizedBox(width: 16),
            _buildStatDetailCard(context, 'Squats', '450 Reps', 'Best: 50 reps', 'Last: Yesterday'),
            const SizedBox(width: 16),
            _buildStatDetailCard(context, 'Jumping Jacks', '480 Reps', 'Best: 60 reps', 'Last: Today'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDetailCard(BuildContext context, String title, String total, String best, String last) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: 128,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(total, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(best, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(last, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
      ),
    );
  }
}
