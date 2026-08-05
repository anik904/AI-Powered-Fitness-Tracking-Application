import 'package:flutter/material.dart';

import '../../../core/widgets/custom_card.dart';

class ChallengeOverviewCard extends StatelessWidget {
  const ChallengeOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
      padding: const EdgeInsets.all(20.0),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day 12 of 30',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              Text(
                '40%',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.4,
            backgroundColor: theme.colorScheme.surfaceVariant,
            color: theme.colorScheme.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(context, 'Completed', '11 Days'),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outlineVariant,
              ),
              _buildStatColumn(context, 'Remaining', '19 Days'),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outlineVariant,
              ),
              _buildStatColumn(context, 'Streak', '🔥 5'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
