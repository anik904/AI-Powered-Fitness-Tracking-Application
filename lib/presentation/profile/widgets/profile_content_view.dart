import 'package:ai_fitness_tracker/widgets/custom_button.dart';
import 'package:ai_fitness_tracker/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/provider/auth_provider.dart';
import '../../../core/provider/challenge_provider.dart';
import '../../../core/provider/exercise_goal_provider.dart';
import '../../../core/provider/sync_provider.dart';
import '../../../core/provider/workout_provider.dart';
import '../../../core/providers/shared_preferences_provider.dart';
import '../../../repository/model/exercise_type.dart';
import '../auth/login_screen.dart';
import 'profile_section_header.dart';
import 'settings_list_tile.dart';
import '../../../widgets/exercise_icon_widget.dart';
import '../../onboarding/welcome_screen.dart';
import '../../../app.dart';

class ProfileContentView extends ConsumerStatefulWidget {
  final bool isSignedIn;
  final VoidCallback onSignOut;
  final VoidCallback onLoginSuccess;

  const ProfileContentView({
    super.key,
    required this.isSignedIn,
    required this.onSignOut,
    required this.onLoginSuccess,
  });

  @override
  ConsumerState<ProfileContentView> createState() => _ProfileContentViewState();
}

class _ProfileContentViewState extends ConsumerState<ProfileContentView> {
  int _goalForType(List<ExerciseGoal> goals, ExerciseType type, int fallback) {
    for (final goal in goals) {
      if (goal.cardData.routeType == type) {
        return goal.target;
      }
    }
    return fallback;
  }

  String _goalSummary({
    required int pushup,
    required int squat,
    required int jumpingJack,
  }) {
    return 'Push-ups: $pushup, Squats: $squat, Jumping Jacks: $jumpingJack reps/day';
  }

  Future<void> _showSingleGoalEditor({
    required BuildContext context,
    required List<ExerciseGoal> goals,
    required ExerciseType type,
    required String title,
    required int fallback,
  }) async {
    String goalText = _goalForType(goals, type, fallback).toString();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Update $title Goal'),
          content: TextFormField(
            onChanged: (value) => goalText = value,
            keyboardType: TextInputType.number,
            initialValue: goalText,
            decoration: const InputDecoration(
              labelText: 'Daily reps',
              suffixText: 'reps',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved != true || !mounted) {
      return;
    }

    final value = int.tryParse(goalText.trim());

    if (value == null || value <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid goal greater than 0.')),
        );
      }
      return;
    }

    final currentPushup = _goalForType(goals, ExerciseType.pushup, 20);
    final currentSquat = _goalForType(goals, ExerciseType.squat, 20);
    final currentJumpingJack = _goalForType(goals, ExerciseType.jumpingJack, 50);

    final pushup = type == ExerciseType.pushup ? value : currentPushup;
    final squat = type == ExerciseType.squat ? value : currentSquat;
    final jumpingJack = type == ExerciseType.jumpingJack ? value : currentJumpingJack;

    final goalNotifier = ref.read(exerciseGoalProvider.notifier);
    goalNotifier.updateGoalByType(type, target: value);

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('pushup_goal', pushup);
    await prefs.setInt('squat_goal', squat);
    await prefs.setInt('jumping_jack_goal', jumpingJack);
    await prefs.setString(
      'user_goal',
      _goalSummary(pushup: pushup, squat: squat, jumpingJack: jumpingJack),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(content: Text('$title goal updated.')),
    );
  }

  Future<void> _handleDeleteAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete All Data'),
          content: const Text(
            'Are you sure you want to delete all your data? This action cannot be undone and will reset your progress, goals, and challenge state.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final authState = ref.read(authProvider);
      final prefs = ref.read(sharedPreferencesProvider);
      final isGuest = !authState.isSignedIn || (prefs.getBool('is_guest_mode') ?? false);

      // Clear data
      await ref.read(authProvider.notifier).deleteAllUserData();

      if (!mounted) return;

      if (!isGuest) {
        // Logged-in user: keep session and navigate to home screen
        Navigator.of(this.context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text('All workout and goal data deleted.')),
        );
      } else {
        // Guest user: navigate to initial welcome screen
        Navigator.of(this.context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleChangePassword(BuildContext context, String? userEmail) async {
    if (!widget.isSignedIn || userEmail == null || userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to change your password.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Text(
            'Send a secure password reset link to $userEmail?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(authProvider.notifier).sendPasswordResetEmail(userEmail);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text('Password reset link sent to $userEmail')),
        );
      } else {
        final error = ref.read(authProvider).error ?? 'Failed to send password reset email';
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(exerciseGoalProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final authState = ref.watch(authProvider);
    final syncState = ref.watch(syncProvider);

    final pushupGoal = _goalForType(goals, ExerciseType.pushup, prefs.getInt('pushup_goal') ?? 20);
    final squatGoal = _goalForType(goals, ExerciseType.squat, prefs.getInt('squat_goal') ?? 20);
    final jumpingJackGoal = _goalForType(goals, ExerciseType.jumpingJack, prefs.getInt('jumping_jack_goal') ?? 50);

    final onboardingName = prefs.getString('onboarding_name');
    final savedName = prefs.getString('user_name');
    final userName = widget.isSignedIn
        ? ((authState.displayName.isNotEmpty && authState.displayName != 'Guest User' && authState.displayName != 'User')
            ? authState.displayName
            : ((savedName != null && savedName.trim().isNotEmpty && savedName != 'User' && savedName != 'Guest User')
                ? savedName.trim()
                : (authState.displayName)))
        : ((savedName != null && savedName.trim().isNotEmpty && savedName != 'User')
            ? savedName.trim()
            : 'Guest User');

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.isSignedIn) {
          await ref.read(authProvider.notifier).refreshUserData();
          await ref.read(syncProvider.notifier).syncNow();
        }
        await Future.wait([
          ref.read(workoutProvider.notifier).loadRecentWorkouts(),
          ref.read(exerciseGoalProvider.notifier).reloadFromDb(),
        ]);
        ref.read(challengeProvider.notifier).reloadFromPrefs();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 1. Profile / Guest Card
          if (widget.isSignedIn)
            CustomCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (authState.email != null)
                          Text(
                            authState.email!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Signed In',
                            style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            CustomCard(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to sync your progress and access your data across devices.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Sign In / Create Account',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                      if (result == true) {
                        widget.onLoginSuccess();
                      }
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 2. Data Synchronization
          const ProfileSectionHeader(title: 'Data Synchronization'),
          CustomCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                SettingsListTile(
                  icon: Icons.sync,
                  title: 'Sync Now',
                  subtitle: syncState.isSyncing
                      ? 'Syncing in background...'
                      : 'Last sync: ${syncState.formattedLastSync}',
                  onTap: () {
                    if (widget.isSignedIn) {
                      ref.read(syncProvider.notifier).syncNow();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Syncing data with cloud in the background...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please sign in to sync your progress')),
                      );
                    }
                  },
                ),
                SwitchListTile(
                  secondary: Icon(Icons.autorenew, color: Theme.of(context).colorScheme.primary),
                  title: Text('Automatic Sync', style: Theme.of(context).textTheme.bodyLarge),
                  value: syncState.autoSyncEnabled,
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    ref.read(syncProvider.notifier).toggleAutoSync(value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Fitness Goals
          const ProfileSectionHeader(title: 'Fitness Goals'),
          CustomCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                SettingsListTile(
                  leading: const ExerciseIconWidget(
                    exerciseType: ExerciseType.pushup,
                    size: 24,
                  ),
                  title: 'Daily Push-up Goal',
                  subtitle: '$pushupGoal Reps',
                  onTap: () {
                    _showSingleGoalEditor(
                      context: context,
                      goals: goals,
                      type: ExerciseType.pushup,
                      title: 'Push-up',
                      fallback: 20,
                    );
                  },
                ),
                SettingsListTile(
                  leading: const ExerciseIconWidget(
                    exerciseType: ExerciseType.squat,
                    size: 24,
                  ),
                  title: 'Daily Squat Goal',
                  subtitle: '$squatGoal Reps',
                  onTap: () {
                    _showSingleGoalEditor(
                      context: context,
                      goals: goals,
                      type: ExerciseType.squat,
                      title: 'Squat',
                      fallback: 20,
                    );
                  },
                ),
                SettingsListTile(
                  leading: const ExerciseIconWidget(
                    exerciseType: ExerciseType.jumpingJack,
                    size: 24,
                  ),
                  title: 'Daily Jumping Jack Goal',
                  subtitle: '$jumpingJackGoal Reps',
                  onTap: () {
                    _showSingleGoalEditor(
                      context: context,
                      goals: goals,
                      type: ExerciseType.jumpingJack,
                      title: 'Jumping Jack',
                      fallback: 50,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Security
          const ProfileSectionHeader(title: 'Security'),
          CustomCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SettingsListTile(
              icon: Icons.lock_reset,
              title: 'Change Password',
              onTap: () => _handleChangePassword(context, authState.email),
            ),
          ),

          const SizedBox(height: 16),

          // 5. Data Management
          const ProfileSectionHeader(title: 'Data Management'),
          CustomCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SettingsListTile(
              icon: Icons.delete_sweep,
              title: 'Delete All Data',
              textColor: Colors.redAccent,
              iconColor: Colors.redAccent,
              onTap: () => _handleDeleteAllData(context),
            ),
          ),

          const SizedBox(height: 16),

          // 6. Information
          const ProfileSectionHeader(title: 'Information'),
          CustomCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                SettingsListTile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                SettingsListTile(
                  icon: Icons.info_outline,
                  title: 'About Application',
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.new_releases, color: Colors.grey),
                  title: Text('App Version', style: Theme.of(context).textTheme.bodyLarge),
                  trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 7. Sign Out (Only if signed in)
          if (widget.isSignedIn) ...[
            CustomButton(
              text: 'Sign Out',
              icon: Icons.logout,
              isDestructive: true,
              onPressed: widget.onSignOut,
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    ),
  );
  }
}
