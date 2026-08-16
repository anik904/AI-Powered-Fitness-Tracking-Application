import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/provider/workout_provider.dart';

import 'widgets/analytics_header.dart';
import 'widgets/overview_cards.dart';
import 'widgets/workout_chart.dart';
import 'widgets/exercise_distribution.dart';
import 'widgets/challenge_progress.dart';
import 'widgets/recent_activity.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AnalyticsHeader(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(workoutProvider.notifier).loadRecentWorkouts();
          },
          child: const CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
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
                child: ChallengeProgress(),
              ),
              SliverToBoxAdapter(
                child: RecentActivity(),
              ),
              SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          ),
        ),
      ),
    );
  }
}
