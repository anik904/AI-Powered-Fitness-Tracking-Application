import '../../../core/network/api_constants.dart';
import '../../model/api/workout_api_model.dart';
import 'api_client.dart';

class WorkoutApiService {
  final ApiClient _apiClient;

  WorkoutApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<WorkoutResponseModel> createWorkout({
    required String firebaseUid,
    required String exerciseType,
    required int reps,
    required DateTime timestamp,
    String? clientId,
  }) async {
    final request = WorkoutCreateRequest(
      exerciseType: exerciseType,
      reps: reps,
      timestamp: timestamp,
      clientId: clientId,
    );

    final response = await _apiClient.post(
      ApiConstants.workoutsEndpoint,
      queryParams: {'firebase_uid': firebaseUid},
      body: request.toJson(),
    );

    return WorkoutResponseModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<WorkoutResponseModel>> bulkCreateWorkouts({
    required String firebaseUid,
    required List<WorkoutCreateRequest> workouts,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.workoutsBulkEndpoint,
      queryParams: {'firebase_uid': firebaseUid},
      body: {'workouts': workouts.map((w) => w.toJson()).toList()},
    );

    return (response as List<dynamic>)
        .map((w) => WorkoutResponseModel.fromJson(w as Map<String, dynamic>))
        .toList();
  }

  Future<List<WorkoutResponseModel>> getWorkouts({
    required String firebaseUid,
    int limit = 100,
    int offset = 0,
    DateTime? since,
  }) async {
    final queryParams = <String, dynamic>{
      'firebase_uid': firebaseUid,
      'limit': limit,
      'offset': offset,
      if (since != null) 'since': since.toUtc().toIso8601String(),
    };

    final response = await _apiClient.get(
      ApiConstants.workoutsEndpoint,
      queryParams: queryParams,
    );

    return (response as List<dynamic>)
        .map((w) => WorkoutResponseModel.fromJson(w as Map<String, dynamic>))
        .toList();
  }

  Future<List<WorkoutResponseModel>> getWorkoutsForToday({
    required String firebaseUid,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.workoutsTodayEndpoint,
      queryParams: {'firebase_uid': firebaseUid},
    );

    return (response as List<dynamic>)
        .map((w) => WorkoutResponseModel.fromJson(w as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearWorkouts({
    required String firebaseUid,
    DateTime? since,
  }) async {
    final queryParams = <String, dynamic>{
      'firebase_uid': firebaseUid,
      if (since != null) 'since': since.toUtc().toIso8601String(),
    };

    await _apiClient.delete(
      ApiConstants.workoutsClearEndpoint,
      queryParams: queryParams,
    );
  }
}
