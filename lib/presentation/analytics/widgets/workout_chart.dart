import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'section_container.dart';
import '../../../widgets/custom_card.dart';
import '../../../core/provider/analytics_provider.dart';

class WorkoutChart extends ConsumerWidget {
  const WorkoutChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsDataProvider);
    final bars = analytics.chartBars;
    final totalRepsInPeriod = analytics.totalReps;

    return SectionContainer(
      title: 'Workout Activity',
      child: CustomCard(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${analytics.currentFilter.label} Overview',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  '$totalRepsInPeriod reps',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bars.map((bar) {
                  return _buildBar(
                    context,
                    label: bar.label,
                    reps: bar.reps,
                    heightRatio: bar.ratio,
                    isToday: bar.isToday,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(
    BuildContext context, {
    required String label,
    required int reps,
    required double heightRatio,
    required bool isToday,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final double maxBarHeight = 120.0;
    final double calculatedHeight = heightRatio > 0
        ? (maxBarHeight * heightRatio).clamp(8.0, maxBarHeight)
        : 4.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (reps > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              reps > 999 ? '${(reps / 1000).toStringAsFixed(1)}k' : '$reps',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: 28,
          height: calculatedHeight,
          decoration: BoxDecoration(
            color: heightRatio == 0
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                : isToday
                    ? colorScheme.primary
                    : colorScheme.primary.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
