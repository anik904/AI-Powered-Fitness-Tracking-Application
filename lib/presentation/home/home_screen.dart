import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/shared_preferences_provider.dart';
import 'widgets/daily_activity.dart';
import 'widgets/daily_motivation_section.dart';
import 'widgets/quick_start_section.dart';
import 'widgets/recent_workout_section.dart';
import 'widgets/home_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final userName = prefs.getString('user_name') ?? 'User';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(userName: userName),
              const SizedBox(height: 24),
              const DailyActivity(),
              const SizedBox(height: 24),
              const DailyMotivationSection(),
              const SizedBox(height: 24),
              const QuickStartSection(),
              const SizedBox(height: 24),
              const RecentWorkoutSection(),
            ],
          ),
        ),
      ),
    );
  }
}
