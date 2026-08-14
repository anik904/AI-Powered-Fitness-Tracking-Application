import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_card.dart';

class DailyActivitySection extends StatelessWidget {
  const DailyActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Icon(Icons.more_horiz, color: AppTheme.textSecondary),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: const [
              _ActivityCard(
                title: 'Jogging',
                value: '22.7',
                unit: 'km',
                progress: 0.7,
                color: Color(0xFF8B5CF6), // Purple
              ),
              SizedBox(width: 16),
              _ActivityCard(
                title: 'Cycling',
                value: '73.2',
                unit: 'km',
                progress: 0.6,
                color: Color(0xFF10B981), // Green
              ),
              SizedBox(width: 16),
              _ActivityCard(
                title: 'Swim',
                value: '3.8',
                unit: 'km',
                progress: 0.8,
                color: Color(0xFFD946EF), // Pink
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final double progress;
  final Color color;

  const _ActivityCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: SizedBox(
        width: 110,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          unit,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
