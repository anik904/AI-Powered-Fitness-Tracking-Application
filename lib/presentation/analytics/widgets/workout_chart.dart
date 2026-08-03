import 'package:flutter/material.dart';
import 'section_container.dart';

import '../../../core/widgets/custom_card.dart';

class WorkoutChart extends StatelessWidget {
  const WorkoutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Workout Activity',
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.zero,
        child: SizedBox(
          height: 180,
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(context, 'Mon', 0.4),
            _buildBar(context, 'Tue', 0.7),
            _buildBar(context, 'Wed', 0.5),
            _buildBar(context, 'Thu', 0.9, isToday: true),
            _buildBar(context, 'Fri', 0.0),
            _buildBar(context, 'Sat', 0.2),
            _buildBar(context, 'Sun', 0.8),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context, String label, double heightRatio, {bool isToday = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 110 * heightRatio,
          decoration: BoxDecoration(
            color: isToday ? colorScheme.primary : colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
