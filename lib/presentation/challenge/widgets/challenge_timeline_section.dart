import 'package:flutter/material.dart';
import '../day_plan_screen.dart';

class ChallengeTimelineSection extends StatelessWidget {
  const ChallengeTimelineSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            crossAxisCount: 6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: 30,
          itemBuilder: (context, index) {
            final day = index + 1;
            bool isCompleted = day < 12;
            bool isCurrent = day == 12;
            bool isLocked = day > 12;

            Color bgColor;
            Color textColor;
            Border? border;

            if (isCompleted) {
              bgColor = theme.colorScheme.primaryContainer;
              textColor = theme.colorScheme.onPrimaryContainer;
              border = Border.all(color: Colors.transparent);
            } else if (isCurrent) {
              bgColor = theme.colorScheme.primary;
              textColor = theme.colorScheme.onPrimary;
              border = Border.all(color: Colors.transparent);
            } else {
              bgColor = theme.colorScheme.surfaceContainerHighest.withOpacity(0.3);
              textColor = theme.colorScheme.onSurfaceVariant;
              border = Border.all(color: Colors.grey.withOpacity(0.15));
            }

            return Material(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (isLocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Day $day is locked! Complete previous days first.')),
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
                    borderRadius: BorderRadius.circular(12),
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
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isCompleted)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(Icons.check, size: 14, color: textColor),
                        )
                      else if (isLocked)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(Icons.lock_outline, size: 12, color: textColor.withOpacity(0.5)),
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
