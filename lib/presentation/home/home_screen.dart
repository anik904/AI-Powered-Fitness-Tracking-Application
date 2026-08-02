import 'package:flutter/material.dart';
import 'widgets/daily_activity_legacy.dart';
import 'widgets/daily_motivation_section.dart';
import 'widgets/quick_start_section.dart';
import 'widgets/recent_workout_section.dart';
import 'widgets/home_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HomeHeader(userName: 'Alex',),
              SizedBox(height: 24),
              DailyActivityLegacy(),
              SizedBox(height: 24),
              DailyMotivationSection(),
              SizedBox(height: 24),
              QuickStartSection(),
              SizedBox(height: 24),
              RecentWorkoutSection(),
            ],
          ),
        ),
      ),
    );
  }
}
