import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repository/model/workout_session.dart';
import '../database/database_helper.dart';

class WorkoutNotifier extends Notifier<List<WorkoutSession>> {
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
