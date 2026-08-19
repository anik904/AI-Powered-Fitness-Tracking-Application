import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/provider/analytics_provider.dart';
import '../day_plan_screen.dart';

class ChallengeTimelineSection extends ConsumerWidget {
  const ChallengeTimelineSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analytics = ref.watch(analyticsDataProvider);
    final completedDays = analytics.challengeCompletedDays;

    final currentDayIndex = analytics.challengeCurrentDayIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.0,
          ),
          itemCount: 30,
          itemBuilder: (context, index) {
            final day = index + 1;
            final bool isCompleted = day <= completedDays;
            final bool isCurrent = day == currentDayIndex && !isCompleted;
            final bool isLocked = day > currentDayIndex;

            Color bgColor;
            Color textColor;
            Border? border;

            if (isCompleted) {
              bgColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.6);
              textColor = theme.colorScheme.onPrimaryContainer;
              border = Border.all(color: Colors.transparent);
            } else if (isCurrent) {
              bgColor = theme.colorScheme.primary;
              textColor = theme.colorScheme.onPrimary;
              border = Border.all(color: Colors.transparent);
            } else {
              bgColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);
              textColor = theme.colorScheme.onSurfaceVariant;
              border = Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2));
            }

            return Material(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  if (isLocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Day $day is locked! Complete previous days first.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DayPlanScreen(day: day, isCompleted: isCompleted),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: border,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (isCompleted)
                        Positioned(
                          top: 3,
                          right: 3,
                          child: Icon(
                            Icons.check_rounded,
                            size: 11,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      else if (isLocked)
                        Positioned(
                          top: 3,
                          right: 3,
                          child: Icon(
                            Icons.lock_outline_rounded,
                            size: 10,
                            color: textColor.withValues(alpha: 0.4),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
