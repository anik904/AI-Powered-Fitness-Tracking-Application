class WorkoutCreateRequest {
  final String exerciseType;
  final int reps;
  final DateTime timestamp;
  final String? clientId;

  WorkoutCreateRequest({
    required this.exerciseType,
    required this.reps,
    required this.timestamp,
    this.clientId,
  });

  Map<String, dynamic> toJson() => {
    'exercise_type': exerciseType,
    'reps': reps,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'client_id': clientId,
  };
}

class WorkoutResponseModel {
  final int id;
  final String exerciseType;
  final int reps;
  final DateTime timestamp;
  final String? clientId;

  WorkoutResponseModel({
    required this.id,
    required this.exerciseType,
    required this.reps,
    required this.timestamp,
    this.clientId,
  });

  factory WorkoutResponseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutResponseModel(
      id: json['id'] as int,
      exerciseType: json['exercise_type'] as String,
      reps: json['reps'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      clientId: json['client_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exercise_type': exerciseType,
    'reps': reps,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'client_id': clientId,
  };
}
