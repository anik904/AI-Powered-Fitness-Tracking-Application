class GoalCreateRequest {
  final String exerciseType;
  final int target;
  final String unit;

  GoalCreateRequest({
    required this.exerciseType,
    required this.target,
    this.unit = 'Reps',
  });

  Map<String, dynamic> toJson() => {
    'exercise_type': exerciseType,
    'target': target,
    'unit': unit,
  };
}

class GoalResponseModel {
  final int id;
  final String exerciseType;
  final int target;
  final String unit;

  GoalResponseModel({
    required this.id,
    required this.exerciseType,
    required this.target,
    required this.unit,
  });

  factory GoalResponseModel.fromJson(Map<String, dynamic> json) {
    return GoalResponseModel(
      id: json['id'] as int,
      exerciseType: json['exercise_type'] as String,
      target: json['target'] as int,
      unit: (json['unit'] as String?) ?? 'Reps',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exercise_type': exerciseType,
    'target': target,
    'unit': unit,
  };
}
