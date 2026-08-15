import 'package:ai_fitness_tracker/repository/model/exercise_type.dart';

class WorkoutSession {
  final int? id;
  final ExerciseType exerciseType;
  final int reps;
  final DateTime timestamp;

  WorkoutSession({
    this.id,
    required this.exerciseType,
    required this.reps,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseType': exerciseType.name,
      'reps': reps,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'],
      exerciseType: ExerciseType.values.firstWhere((e) => e.name == map['exerciseType']),
      reps: map['reps'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
