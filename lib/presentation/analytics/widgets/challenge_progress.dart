import 'package:flutter/material.dart';
import 'section_container.dart';

import '../../../widgets/custom_card.dart';

class ChallengeProgress extends StatelessWidget {
  const ChallengeProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: '30-Day Challenge',
      child: CustomCard(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Day 12 / 30', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('40%', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 12 / 30,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('12 Days Completed', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                Text('18 Days Remaining', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
