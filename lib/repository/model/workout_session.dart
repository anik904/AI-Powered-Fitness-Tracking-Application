import 'package:uuid/uuid.dart';
import 'exercise_type.dart';

class WorkoutSession {
  final int? id;
  final ExerciseType exerciseType;
  final int reps;
  final DateTime timestamp;
  final String clientId;

  WorkoutSession({
    this.id,
    required this.exerciseType,
    required this.reps,
    required this.timestamp,
    String? clientId,
  }) : clientId = clientId ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseType': exerciseType.name,
      'reps': reps,
      'timestamp': timestamp.toIso8601String(),
      'clientId': clientId,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as int?,
      exerciseType: ExerciseType.values.firstWhere(
        (e) => e.name == map['exerciseType'],
        orElse: () => ExerciseType.pushup,
      ),
      reps: map['reps'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      clientId: map['clientId'] as String?,
    );
  }

  WorkoutSession copyWith({
    int? id,
    ExerciseType? exerciseType,
    int? reps,
    DateTime? timestamp,
    String? clientId,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      exerciseType: exerciseType ?? this.exerciseType,
      reps: reps ?? this.reps,
      timestamp: timestamp ?? this.timestamp,
      clientId: clientId ?? this.clientId,
    );
  }
}
