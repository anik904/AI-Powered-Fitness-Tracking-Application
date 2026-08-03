import 'package:flutter/material.dart';
import 'section_container.dart';

import '../../../core/widgets/custom_card.dart';

class ExerciseDistribution extends StatelessWidget {
  const ExerciseDistribution({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Exercise Distribution',
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.zero,
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 16,
                    color: Colors.blue.shade100,
                  ),
                  CircularProgressIndicator(
                    value: 0.65,
                    strokeWidth: 16,
                    color: Colors.blue.shade400,
                  ),
                  CircularProgressIndicator(
                    value: 0.35,
                    strokeWidth: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Center(
                    child: Text(
                      '100%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(context, 'Push-ups', 35, Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  _buildLegendItem(context, 'Squats', 30, Colors.blue.shade400),
                  const SizedBox(height: 12),
                  _buildLegendItem(context, 'Jumping Jacks', 35, Colors.blue.shade100),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String title, int percentage, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text('$percentage%', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
