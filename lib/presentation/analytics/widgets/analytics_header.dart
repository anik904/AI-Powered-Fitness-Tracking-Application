import 'package:flutter/material.dart';

class AnalyticsHeader extends StatelessWidget implements PreferredSizeWidget {
  const AnalyticsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Analytics'),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButton<String>(
            value: '7 Days',
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            items: ['7 Days', '30 Days', 'All Time']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
