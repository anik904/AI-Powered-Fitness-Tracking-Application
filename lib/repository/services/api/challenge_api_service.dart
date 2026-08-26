import '../../../core/network/api_constants.dart';
import '../../model/api/challenge_api_model.dart';
import 'api_client.dart';

class ChallengeApiService {
  final ApiClient _apiClient;

  ChallengeApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ChallengeResponseModel?> getChallenge({required String firebaseUid}) async {
    final response = await _apiClient.get(
      ApiConstants.challengeEndpoint,
      queryParams: {'firebase_uid': firebaseUid},
    );

    if (response == null) return null;
    return ChallengeResponseModel.fromJson(response as Map<String, dynamic>);
  }

  Future<ChallengeResponseModel> startChallenge({required String firebaseUid}) async {
    final response = await _apiClient.post(
      ApiConstants.challengeStartEndpoint,
      queryParams: {'firebase_uid': firebaseUid},
    );

    return ChallengeResponseModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> resetChallenge({required String firebaseUid}) async {
    await _apiClient.post(
      ApiConstants.challengeResetEndpoint,
      queryParams: {'firebase_uid': firebaseUid},
    );
  }
}
