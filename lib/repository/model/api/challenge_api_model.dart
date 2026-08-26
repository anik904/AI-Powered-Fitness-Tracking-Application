class ChallengeCreateRequest {
  final bool isStarted;
  final DateTime? startDate;

  ChallengeCreateRequest({
    this.isStarted = true,
    this.startDate,
  });

  Map<String, dynamic> toJson() => {
    'is_started': isStarted,
    'start_date': startDate?.toUtc().toIso8601String(),
  };
}

class ChallengeResponseModel {
  final int id;
  final bool isStarted;
  final DateTime? startDate;

  ChallengeResponseModel({
    required this.id,
    required this.isStarted,
    this.startDate,
  });

  factory ChallengeResponseModel.fromJson(Map<String, dynamic> json) {
    return ChallengeResponseModel(
      id: json['id'] as int,
      isStarted: json['is_started'] as bool,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'is_started': isStarted,
    'start_date': startDate?.toUtc().toIso8601String(),
  };
}
