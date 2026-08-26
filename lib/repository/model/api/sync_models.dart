import 'challenge_api_model.dart';
import 'goal_api_model.dart';
import 'user_api_model.dart';
import 'workout_api_model.dart';

class SyncUploadRequest {
  final List<WorkoutCreateRequest> workouts;
  final List<GoalCreateRequest> goals;
  final ChallengeCreateRequest? challenge;

  SyncUploadRequest({
    this.workouts = const [],
    this.goals = const [],
    this.challenge,
  });

  Map<String, dynamic> toJson() => {
    'workouts': workouts.map((w) => w.toJson()).toList(),
    'goals': goals.map((g) => g.toJson()).toList(),
    if (challenge != null) 'challenge': challenge!.toJson(),
  };
}

class SyncUploadResponse {
  final String status;
  final int workoutsCreated;
  final int workoutsSkipped;
  final int goalsSynced;
  final bool challengeSynced;

  SyncUploadResponse({
    required this.status,
    required this.workoutsCreated,
    required this.workoutsSkipped,
    required this.goalsSynced,
    required this.challengeSynced,
  });

  factory SyncUploadResponse.fromJson(Map<String, dynamic> json) {
    return SyncUploadResponse(
      status: json['status'] as String? ?? 'ok',
      workoutsCreated: json['workouts_created'] as int? ?? 0,
      workoutsSkipped: json['workouts_skipped'] as int? ?? 0,
      goalsSynced: json['goals_synced'] as int? ?? 0,
      challengeSynced: json['challenge_synced'] as bool? ?? false,
    );
  }
}

class SyncDownloadResponse {
  final UserResponseModel user;
  final List<WorkoutResponseModel> workouts;
  final List<GoalResponseModel> goals;
  final ChallengeResponseModel? challenge;

  SyncDownloadResponse({
    required this.user,
    this.workouts = const [],
    this.goals = const [],
    this.challenge,
  });

  factory SyncDownloadResponse.fromJson(Map<String, dynamic> json) {
    final workoutsList = (json['workouts'] as List<dynamic>? ?? [])
        .map((w) => WorkoutResponseModel.fromJson(w as Map<String, dynamic>))
        .toList();

    final goalsList = (json['goals'] as List<dynamic>? ?? [])
        .map((g) => GoalResponseModel.fromJson(g as Map<String, dynamic>))
        .toList();

    final challengeData = json['challenge'] != null
        ? ChallengeResponseModel.fromJson(json['challenge'] as Map<String, dynamic>)
        : null;

    return SyncDownloadResponse(
      user: UserResponseModel.fromJson(json['user'] as Map<String, dynamic>),
      workouts: workoutsList,
      goals: goalsList,
      challenge: challengeData,
    );
  }
}
