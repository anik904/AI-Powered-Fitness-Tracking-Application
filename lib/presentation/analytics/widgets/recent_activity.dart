import 'package:flutter/material.dart';
import 'section_container.dart';

import '../../../widgets/custom_card.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Recent Activity',
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            _buildActivityItem(context, 'Today, 8:00 AM', 'Push-ups', '45 Reps', '10 mins'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),
            _buildActivityItem(context, 'Yesterday, 7:30 AM', 'Squats', '50 Reps', '12 mins'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),
            _buildActivityItem(context, 'Mon, 6:45 AM', 'Jumping Jacks', '60 Reps', '8 mins'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String date, String exercise, String reps, String duration) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exercise, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(reps, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(duration, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}
