import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

const List<String> dailyFitnessTips = [
  'Consistency is key. Even a 10-minute workout makes a difference!',
  'Keep your back straight and chest proud during squats to protect your spine.',
  'Stay hydrated! Drink a glass of water 20-30 minutes before exercising.',
  'Focus on quality over quantity: controlled reps build stronger muscle fibers.',
  'Warm up with light dynamic movements to prime your joints and muscles.',
  'Exhale as you push or exert, and inhale as you lower or reset.',
  'Rest days are crucial for muscle recovery, growth, and injury prevention.',
  'Land softly on the balls of your feet during jumping jacks to protect your joints.',
  'Full range of motion recruits more muscle fibers for maximum fitness gains.',
  'Small daily efforts compound into extraordinary long-term transformations.',
  'Fuel your body with a balanced mix of protein and carbs after training.',
  'Listen to your body: rest or adjust intensity whenever you feel sharp pain.',
  'Keep your elbows at a 45-degree angle during push-ups to protect your shoulders.',
  'Track your workouts daily to celebrate progress and maintain momentum.',
  'Stretch your major muscle groups post-workout to improve mobility.',
  'Quality sleep is essential for muscle repair and nervous system recovery.',
  'Engage your core during every movement for better stability and power.',
  'Set clear, achievable milestones and celebrate each step forward.',
  'Drive through your heels when standing up from squats for maximum glute power.',
  'Fitness is a lifestyle journey. Enjoy every step and keep moving forward!',
];

class DailyMotivationSection extends StatefulWidget {
  const DailyMotivationSection({super.key});

  @override
  State<DailyMotivationSection> createState() => _DailyMotivationSectionState();
}

class _DailyMotivationSectionState extends State<DailyMotivationSection> {
  late int _tipIndex;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    _tipIndex = dayOfYear % dailyFitnessTips.length;
  }

  void _nextTip() {
    setState(() {
      _tipIndex = (_tipIndex + 1) % dailyFitnessTips.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTip = dailyFitnessTips[_tipIndex];

    return InkWell(
      onTap: _nextTip,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.textSecondary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Tip',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    currentTip,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.3,
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

