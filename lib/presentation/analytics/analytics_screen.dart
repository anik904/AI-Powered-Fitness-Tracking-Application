import 'package:flutter/material.dart';

import 'widgets/analytics_header.dart';
import 'widgets/overview_cards.dart';
import 'widgets/workout_chart.dart';
import 'widgets/exercise_distribution.dart';
import 'widgets/exercise_stats.dart';
import 'widgets/challenge_progress.dart';
import 'widgets/recent_activity.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AnalyticsHeader(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: OverviewCards(),
            ),
            SliverToBoxAdapter(
              child: WorkoutChart(),
            ),
            SliverToBoxAdapter(
              child: ExerciseDistribution(),
            ),
            SliverToBoxAdapter(
              child: ExerciseStats(),
            ),
            SliverToBoxAdapter(
              child: ChallengeProgress(),
            ),
            SliverToBoxAdapter(
              child: RecentActivity(),
            ),
            SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
}
