import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/provider/analytics_provider.dart';

class AnalyticsHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AnalyticsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(analyticsFilterProvider);

    return AppBar(
      title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButton<AnalyticsTimeFilter>(
            value: currentFilter,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            items: AnalyticsTimeFilter.values
                .map((filter) => DropdownMenuItem(
                      value: filter,
                      child: Text(filter.label),
                    ))
                .toList(),
            onChanged: (newFilter) {
              if (newFilter != null) {
                ref.read(analyticsFilterProvider.notifier).setFilter(newFilter);
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
