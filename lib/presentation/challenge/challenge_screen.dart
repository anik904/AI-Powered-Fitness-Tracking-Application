import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/provider/analytics_provider.dart';
import '../../../core/provider/challenge_provider.dart';
import 'widgets/challenge_overview_card.dart';
import 'widgets/challenge_rules_card.dart';
import 'widgets/challenge_timeline_section.dart';
import 'widgets/progress_milestone_section.dart';
import 'widgets/todays_workout_section.dart';

class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsDataProvider);
    final isChallengeActive = analytics.isChallengeActive;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '30-Day Challenge',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          if (isChallengeActive) ...[
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
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
            IconButton(
              tooltip: 'Reset Challenge',
              icon: const Icon(Icons.restart_alt),
              onPressed: () => _showResetDialog(context, ref),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      body: isChallengeActive
          ? SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ChallengeOverviewCard(),
                  const SizedBox(height: 24),
                  const ProgressMilestoneSection(),
                  const SizedBox(height: 24),
                  const TodaysWorkoutSection(),
                  const SizedBox(height: 24),
                  const ChallengeTimelineSection(),
                  const SizedBox(height: 24),
                  const ChallengeRulesCard(),
                  const SizedBox(height: 24),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => _showResetDialog(context, ref),
                      icon: const Icon(Icons.restart_alt, color: Colors.redAccent, size: 18),
                      label: const Text(
                        'Reset 30-Day Challenge',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Are you ready?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Commit to 30 days of continuous workouts and build a lasting habit. Transform your life today by following these simple rules:',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInstructionItem(
                    context,
                    icon: Icons.fitness_center,
                    title: 'Daily Exercise',
                    description:
                        'Complete at least one exercise every day to advance your 30-day challenge.',
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionItem(
                    context,
                    icon: Icons.track_changes,
                    title: 'Track Your Progress',
                    description:
                        'Your reps, completed days, and workouts are recorded automatically.',
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionItem(
                    context,
                    icon: Icons.local_fire_department,
                    title: 'Build Your Streak',
                    description:
                        'Exercise consistently every day to grow your active streak and build a permanent habit.',
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionItem(
                    context,
                    icon: Icons.workspace_premium,
                    title: 'Unlock Milestones',
                    description:
                        'Reach key milestone badges on Days 1, 7, 14, 21, and finish strong on Day 30.',
                  ),
                  const SizedBox(height: 48),
                  FilledButton(
                    onPressed: () {
                      ref.read(challengeProvider.notifier).startChallenge();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start 30-Day Challenge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Challenge?'),
          content: const Text(
            'This will reset your 30-day challenge progress back to the beginning. Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref.read(challengeProvider.notifier).resetChallenge();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('30-Day Challenge has been reset.')),
                  );
                }
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
