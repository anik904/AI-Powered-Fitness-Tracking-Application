import '../../../core/network/api_constants.dart';
import '../../model/api/goal_api_model.dart';
import 'api_client.dart';

class GoalApiService {
  final ApiClient _apiClient;

  GoalApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<GoalResponseModel>> getGoals({required String firebaseUid}) async {
    final response = await _apiClient.get(
      ApiConstants.goalsEndpoint,
      queryParams: {'firebase_uid': firebaseUid},
    );

    return (response as List<dynamic>)
        .map((g) => GoalResponseModel.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  Future<GoalResponseModel> saveGoal({
    required String firebaseUid,
    required String exerciseType,
    required int target,
    String unit = 'Reps',
  }) async {
    final request = GoalCreateRequest(
      exerciseType: exerciseType,
      target: target,
      unit: unit,
    );

    final response = await _apiClient.post(
      ApiConstants.goalsEndpoint,
      queryParams: {'firebase_uid': firebaseUid},
      body: request.toJson(),
    );

    return GoalResponseModel.fromJson(response as Map<String, dynamic>);
  }

  Future<GoalResponseModel> getGoalByType({
    required String firebaseUid,
    required String exerciseType,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.goalsEndpoint}$exerciseType',
      queryParams: {'firebase_uid': firebaseUid},
    );

    return GoalResponseModel.fromJson(response as Map<String, dynamic>);
  }
}
