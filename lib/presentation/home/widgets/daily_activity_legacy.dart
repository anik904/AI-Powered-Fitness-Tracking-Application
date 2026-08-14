import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

import '../../../widgets/custom_card.dart';

class DailyActivityLegacy extends StatelessWidget {
  const DailyActivityLegacy({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        CustomCard(
          color: AppTheme.accentColor.withOpacity(0.4),
          padding: const EdgeInsets.all(20),
          margin: EdgeInsets.zero,
          child: Row(
            children: [
              // Progress Circle
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.67,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.background,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '67%',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Goal',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Stats List
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _ActivityStat(icon: Icons.fitness_center, title: 'Push up', value: '20/24'),
                    SizedBox(height: 12),
                    _ActivityStat(icon: Icons.accessibility_new, title: 'Squat', value: '3/10'),
                    SizedBox(height: 12),
                    _ActivityStat(icon: Icons.timer, title: 'Jumping Jack', value: '5/6m'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ActivityStat({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          value,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
