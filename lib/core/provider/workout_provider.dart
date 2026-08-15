import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repository/model/workout_session.dart';
import '../database/database_helper.dart';

class WorkoutNotifier extends Notifier<List<WorkoutSession>> {
  @override
  List<WorkoutSession> build() {
    // Load recent workouts after build
    Future.microtask(() => loadRecentWorkouts());
    return [];
  }

  Future<void> loadRecentWorkouts() async {
    final workouts = await DatabaseHelper.instance.getRecentWorkouts();
    state = workouts;
  }

  Future<void> addWorkout(WorkoutSession session) async {
    await DatabaseHelper.instance.insertWorkout(session);
    // Reload to reflect changes
    await loadRecentWorkouts();
  }
}

final workoutProvider = NotifierProvider<WorkoutNotifier, List<WorkoutSession>>(() {
  return WorkoutNotifier();
});

// A derived provider to get today's workout sessions
final todayWorkoutProvider = Provider<List<WorkoutSession>>((ref) {
  // Since workoutProvider holds recent workouts and orders by time,
  // we can just filter them for today to get a quick summary.
  // For a robust implementation, we might want to query DB explicitly for today's stats,
  // but if recent workouts has enough limit, this works for UI.
  final allWorkouts = ref.watch(workoutProvider);
  final now = DateTime.now();
  return allWorkouts.where((w) => 
    w.timestamp.year == now.year &&
    w.timestamp.month == now.month &&
    w.timestamp.day == now.day
  ).toList();
});
