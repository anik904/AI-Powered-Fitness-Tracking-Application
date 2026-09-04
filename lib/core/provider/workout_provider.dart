import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repository/model/workout_session.dart';
import '../../repository/services/sync/sync_service.dart';
import '../database/database_helper.dart';
import 'auth_provider.dart';
import 'challenge_provider.dart' as import_challenge;

class WorkoutNotifier extends Notifier<List<WorkoutSession>> {
  final SyncService _syncService = SyncService();

  @override
  List<WorkoutSession> build() {
    Future.microtask(() => loadRecentWorkouts());
    return [];
  }

  Future<void> loadRecentWorkouts() async {
    final workouts = await DatabaseHelper.instance.getRecentWorkouts(limit: 100);
    state = workouts;
  }

  Future<void> addWorkout(WorkoutSession session) async {
    await DatabaseHelper.instance.insertWorkout(session);
    await loadRecentWorkouts();

    final user = ref.read(authProvider).user;
    if (user != null) {
      _syncService.syncWorkoutInBackground(
        firebaseUid: user.uid,
        session: session,
      );
    }
  }

  Future<void> clearAllWorkouts({DateTime? since}) async {
    // Clear locally first
    await DatabaseHelper.instance.clearWorkouts(since: since);
    await loadRecentWorkouts();

    // Fire background sync non-blockingly
    final user = ref.read(authProvider).user;
    if (user != null) {
      _syncService.syncClearWorkoutsInBackground(user.uid, since: since);
    }
  }
}

final workoutProvider = NotifierProvider<WorkoutNotifier, List<WorkoutSession>>(() {
  return WorkoutNotifier();
});

final todayWorkoutProvider = Provider<List<WorkoutSession>>((ref) {
  final allWorkouts = ref.watch(workoutProvider);
  final now = DateTime.now();
  return allWorkouts.where((w) => 
    w.timestamp.year == now.year &&
    w.timestamp.month == now.month &&
    w.timestamp.day == now.day
  ).toList();
});

final challengeTodayWorkoutProvider = Provider<List<WorkoutSession>>((ref) {
  final todayWorkouts = ref.watch(todayWorkoutProvider);
  final challengeState = ref.watch(import_challenge.challengeProvider);
  
  if (!challengeState.isStarted || challengeState.startDate == null) {
    return [];
  }
  
  return todayWorkouts.where((w) => !w.timestamp.isBefore(challengeState.startDate!)).toList();
});
