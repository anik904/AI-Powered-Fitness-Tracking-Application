import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/provider/analytics_provider.dart';
import '../../../widgets/custom_card.dart';

class ProgressMilestoneSection extends ConsumerWidget {
  const ProgressMilestoneSection({super.key});

  static const List<_MilestoneData> _milestones = [
    _MilestoneData(
      day: 1,
      name: 'Kickoff',
      badge: 'Day 1',
      icon: Icons.flag_rounded,
      color: Color(0xFF3B82F6), // Blue
    ),
    _MilestoneData(
      day: 7,
      name: '1 Week',
      badge: 'Day 7',
      icon: Icons.shield_rounded,
      color: Color(0xFF10B981), // Emerald
    ),
    _MilestoneData(
      day: 14,
      name: 'Halfway',
      badge: 'Day 14',
      icon: Icons.bolt_rounded,
      color: Color(0xFFF59E0B), // Amber
    ),
    _MilestoneData(
      day: 21,
      name: '3 Weeks',
      badge: 'Day 21',
      icon: Icons.diamond_rounded,
      color: Color(0xFF8B5CF6), // Purple
    ),
    _MilestoneData(
      day: 30,
      name: 'Champion',
      badge: 'Day 30',
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFEC4899), // Pink / Gold
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analytics = ref.watch(analyticsDataProvider);
    final completedDays = analytics.challengeCompletedDays;

    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Milestones',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),

          // Stepper Track
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_milestones.length * 2 - 1, (index) {
              if (index.isEven) {
                final mIndex = index ~/ 2;
                final milestone = _milestones[mIndex];
                final isUnlocked = completedDays >= milestone.day;
                final isCurrent = !isUnlocked &&
                    (mIndex == 0 || completedDays >= _milestones[mIndex - 1].day);

                return _buildMilestoneNode(
                  context: context,
                  milestone: milestone,
                  isUnlocked: isUnlocked,
                  isCurrent: isCurrent,
                );
              } else {
                final prevIndex = index ~/ 2;
                final nextMilestoneDay = _milestones[prevIndex + 1].day;
                final isConnectorActive = completedDays >= nextMilestoneDay;

                return Expanded(
                  child: Container(
                    height: 3.5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isConnectorActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneNode({
    required BuildContext context,
    required _MilestoneData milestone,
    required bool isUnlocked,
    required bool isCurrent,
  }) {
    final theme = Theme.of(context);

    Color nodeBg;
    Color iconColor;
    Border? border;

    if (isUnlocked) {
      nodeBg = milestone.color;
      iconColor = Colors.white;
    } else if (isCurrent) {
      nodeBg = theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
      iconColor = theme.colorScheme.primary;
      border = Border.all(color: theme.colorScheme.primary, width: 2);
    } else {
      nodeBg = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
      iconColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: nodeBg,
                border: border,
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: milestone.color.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : (isCurrent
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null),
              ),
              child: Icon(
                isUnlocked ? milestone.icon : (isCurrent ? milestone.icon : Icons.lock_outline_rounded),
                color: iconColor,
                size: 20,
              ),
            ),
            if (isUnlocked)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          milestone.badge,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: isUnlocked || isCurrent ? FontWeight.bold : FontWeight.w500,
            color: isUnlocked
                ? milestone.color
                : (isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant),
            fontSize: 11,
          ),
        ),
        Text(
          milestone.name,
          style: TextStyle(
            fontSize: 10,
            color: isUnlocked || isCurrent
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _MilestoneData {
  final int day;
  final String name;
  final String badge;
  final IconData icon;
  final Color color;

  const _MilestoneData({
    required this.day,
    required this.name,
    required this.badge,
    required this.icon,
    required this.color,
  });
}
