import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'section_container.dart';
import '../../../widgets/custom_card.dart';
import '../../../core/provider/analytics_provider.dart';
import '../../../repository/model/exercise_type.dart';

class ExerciseDistribution extends ConsumerWidget {
  const ExerciseDistribution({super.key});

  Color _getExerciseColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.pushup:
        return const Color(0xFF84CC16);
      case ExerciseType.squat:
        return const Color(0xFF06B6D4);
      case ExerciseType.jumpingJack:
        return const Color(0xFFA855F7);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsDataProvider);
    final distribution = analytics.distribution;
    final totalReps = analytics.totalReps;

    return SectionContainer(
      title: 'Exercise Distribution',
      child: CustomCard(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.zero,
        child: totalReps == 0
            ? const SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'No exercise data for this time period',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _DonutChartPainter(
                        distribution: distribution,
                        getColor: _getExerciseColor,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$totalReps',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            Text(
                              'Total Reps',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: distribution.map((item) {
                        final percentage = (item.percentage * 100).round();
                        final color = _getExerciseColor(item.exerciseType);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: _buildLegendItem(
                            context,
                            item.exerciseType.displayName,
                            percentage,
                            item.totalReps,
                            color,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String title,
    int percentage,
    int reps,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$percentage%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<ExerciseDistributionData> distribution;
  final Color Function(ExerciseType) getColor;

  _DonutChartPainter({
    required this.distribution,
    required this.getColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 14.0;

    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    double startAngle = -math.pi / 2;

    for (final item in distribution) {
      if (item.percentage <= 0) continue;

      final sweepAngle = 2 * math.pi * item.percentage;
      final paint = Paint()
        ..color = getColor(item.exerciseType)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.distribution != distribution;
  }
}
