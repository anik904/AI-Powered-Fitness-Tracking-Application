import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shared_preferences_provider.dart';
import 'workout_provider.dart';

class ChallengeState {
  final bool isStarted;
  final DateTime? startDate;

  const ChallengeState({
    required this.isStarted,
    this.startDate,
  });
}

class ChallengeNotifier extends Notifier<ChallengeState> {
  static const _challengeStartedKey = 'challenge_started';
  static const _challengeStartDateKey = 'challenge_start_date';

  @override
  ChallengeState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isStarted = prefs.getBool(_challengeStartedKey) ?? false;
    final startDateString = prefs.getString(_challengeStartDateKey);
    final startDate = startDateString != null ? DateTime.parse(startDateString) : null;
    
    return ChallengeState(
      isStarted: isStarted,
      startDate: startDate,
    );
  }

  Future<void> startChallenge() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final now = DateTime.now();
    await prefs.setBool(_challengeStartedKey, true);
    await prefs.setString(_challengeStartDateKey, now.toIso8601String());
    
    state = ChallengeState(
      isStarted: true,
      startDate: now,
    );
  }

  Future<void> restartChallenge() async {
    final currentStartDate = state.startDate;
    await ref.read(workoutProvider.notifier).clearAllWorkouts(since: currentStartDate);
    await startChallenge();
  }

  Future<void> resetChallenge() async {
    final currentStartDate = state.startDate;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_challengeStartedKey);
    await prefs.remove(_challengeStartDateKey);
    await ref.read(workoutProvider.notifier).clearAllWorkouts(since: currentStartDate);
    
    state = const ChallengeState(
      isStarted: false,
      startDate: null,
    );
  }
}

final challengeProvider = NotifierProvider<ChallengeNotifier, ChallengeState>(() {
  return ChallengeNotifier();
});
