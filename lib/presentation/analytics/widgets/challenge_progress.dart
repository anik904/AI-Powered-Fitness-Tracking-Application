import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'section_container.dart';
import '../../../widgets/custom_card.dart';
import '../../../core/provider/analytics_provider.dart';
import '../../../core/provider/challenge_provider.dart';
class ChallengeProgress extends ConsumerWidget {
  const ChallengeProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsDataProvider);
    final isChallengeActive = analytics.isChallengeActive;
    
    if (!isChallengeActive) {
      return SectionContainer(
        title: '30-Day Challenge',
        child: CustomCard(
          padding: const EdgeInsets.all(20),
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Are you ready for a challenge?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Commit to 30 days of continuous workouts and build a lasting habit.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ref.read(challengeProvider.notifier).startChallenge();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Start 30-Day Challenge'),
              ),
            ],
          ),
        ),
      );
    }

    final completedDays = analytics.challengeCompletedDays;
    final remainingDays = analytics.challengeRemainingDays;
    final percentage = analytics.challengePercentage;
    final progressValue = (completedDays / 30).clamp(0.0, 1.0);
    final challengeCompleted = completedDays >= 30;

    return SectionContainer(
      title: '30-Day Challenge',
      child: CustomCard(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  challengeCompleted ? 'Challenge Completed!' : 'Day $completedDays / 30',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: challengeCompleted ? Theme.of(context).colorScheme.primary : null,
                      ),
                ),
                if (!challengeCompleted)
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 12,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (challengeCompleted)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(challengeProvider.notifier).restartChallenge();
                  },
                  child: const Text('Restart Challenge'),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completedDays ${completedDays == 1 ? 'Day' : 'Days'} Completed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    '$remainingDays ${remainingDays == 1 ? 'Day' : 'Days'} Remaining',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
