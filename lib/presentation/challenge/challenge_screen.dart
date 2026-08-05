import 'package:flutter/material.dart';
import 'widgets/challenge_overview_card.dart';
import 'widgets/challenge_rules_card.dart';
import 'widgets/challenge_timeline_section.dart';
import 'widgets/progress_milestone_section.dart';
import 'widgets/todays_workout_section.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('30-Day Challenge', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              'In Progress',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ChallengeOverviewCard(),
            SizedBox(height: 24),
            ProgressMilestoneSection(),
            SizedBox(height: 24),
            TodaysWorkoutSection(),
            SizedBox(height: 24),
            ChallengeTimelineSection(),
            SizedBox(height: 24),
            ChallengeRulesCard(),
            SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
