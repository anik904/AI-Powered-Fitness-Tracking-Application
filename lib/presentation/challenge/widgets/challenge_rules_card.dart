import 'package:flutter/material.dart';

import '../../../widgets/custom_card.dart';

class ChallengeRulesCard extends StatelessWidget {
  const ChallengeRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      padding: const EdgeInsets.all(16.0),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Challenge Rules',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRuleItem(context, 'Complete at least one exercise per day'),
          _buildRuleItem(context, 'Workout reps and progress are saved automatically'),
          _buildRuleItem(context, 'Your streak increases with every consecutive active day'),
          _buildRuleItem(context, 'Milestones unlock on Days 1, 7, 14, 21, and 30'),
          _buildRuleItem(context, 'You can reset or restart the challenge at any time'),
        ],
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Icon(
              Icons.circle,
              size: 6,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
