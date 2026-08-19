import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/custom_card.dart';
import '../../../core/provider/analytics_provider.dart';

class ChallengeOverviewCard extends ConsumerWidget {
  const ChallengeOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analytics = ref.watch(analyticsDataProvider);
    final completedDays = analytics.challengeCompletedDays;
    final remainingDays = analytics.challengeRemainingDays;
    final percentage = analytics.challengePercentage;
    final challengeStreak = analytics.challengeStreak;

    final currentDayIndex = analytics.challengeCurrentDayIndex;

    return CustomCard(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(20.0),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day $currentDayIndex of 30',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              Text(
                '$percentage%',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (completedDays / 30).clamp(0.0, 1.0),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: theme.colorScheme.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(context, 'Completed', '$completedDays Days'),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outlineVariant,
              ),
              _buildStatColumn(context, 'Remaining', '$remainingDays Days'),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outlineVariant,
              ),
              _buildStatColumn(context, 'Streak', '🔥 $challengeStreak'),
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
