import 'package:flutter/material.dart';

class ProgressMilestoneSection extends StatelessWidget {
  const ProgressMilestoneSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMilestone(context, 1, true),
            _buildConnector(context, true),
            _buildMilestone(context, 7, true),
            _buildConnector(context, false),
            _buildMilestone(context, 14, false),
            _buildConnector(context, false),
            _buildMilestone(context, 21, false),
            _buildConnector(context, false),
            _buildMilestone(context, 30, false),
          ],
        ),
      ],
    );
  }

  Widget _buildConnector(BuildContext context, bool active) {
    return Expanded(
      child: Container(
        height: 4,
        color: active 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.surfaceVariant,
      ),
    );
  }

  Widget _buildMilestone(BuildContext context, int day, bool active) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
          ),
          alignment: Alignment.center,
          child: Text(
            active ? '✓' : '$day',
            style: TextStyle(
              color: active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Day $day',
          style: theme.textTheme.labelSmall?.copyWith(
            color: active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
