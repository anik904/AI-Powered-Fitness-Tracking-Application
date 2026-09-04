import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/provider/auth_provider.dart';
import '../../core/provider/challenge_provider.dart';
import '../../core/provider/exercise_goal_provider.dart';
import '../../core/provider/sync_provider.dart';
import '../../core/provider/workout_provider.dart';
import '../../core/providers/shared_preferences_provider.dart';
import '../../core/theme/app_theme.dart';
import '../profile/profile_screeen.dart';
import 'widgets/daily_activity.dart';
import 'widgets/daily_motivation_section.dart';
import 'widgets/quick_start_section.dart';
import 'widgets/recent_workout_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedName = prefs.getString('user_name');
    final onboardingName = prefs.getString('onboarding_name');

    final String userName;
    if (authState.isSignedIn) {
      if (authState.displayName.isNotEmpty && authState.displayName != 'Guest User' && authState.displayName != 'User') {
        userName = authState.displayName;
      } else if (savedName != null && savedName.trim().isNotEmpty && savedName != 'Guest User' && savedName != 'User') {
        userName = savedName.trim();
      } else {
        userName = authState.displayName;
      }
    } else {
      if (savedName != null && savedName.trim().isNotEmpty && savedName != 'User') {
        userName = savedName.trim();
      } else {
        userName = 'Guest User';
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Hi, $userName',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.cardColor,
                child: Icon(Icons.person, color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            final auth = ref.read(authProvider);
            if (auth.isSignedIn) {
              await ref.read(authProvider.notifier).refreshUserData();
              await ref.read(syncProvider.notifier).syncNow();
            }
            await Future.wait([
              ref.read(workoutProvider.notifier).loadRecentWorkouts(),
              ref.read(exerciseGoalProvider.notifier).reloadFromDb(),
            ]);
            ref.read(challengeProvider.notifier).reloadFromPrefs();
          },
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DailyActivity(),
                SizedBox(height: 18),
                DailyMotivationSection(),
                SizedBox(height: 18),
                QuickStartSection(),
                SizedBox(height: 18),
                RecentWorkoutSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

