import '../../../core/network/api_constants.dart';
import '../../model/api/user_api_model.dart';
import 'api_client.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<UserResponseModel> registerUser({
    required String firebaseUid,
    required String email,
    String? displayName,
  }) async {
    final request = UserRegisterRequest(
      firebaseUid: firebaseUid,
      email: email,
      displayName: displayName,
    );

    final response = await _apiClient.post(
      ApiConstants.registerEndpoint,
      body: request.toJson(),
    );

    return UserResponseModel.fromJson(response as Map<String, dynamic>);
  }

  Future<UserResponseModel> getCurrentUser(String firebaseUid) async {
    final response = await _apiClient.get(
      ApiConstants.meEndpoint,
      queryParams: {'firebase_uid': firebaseUid},
    );

    return UserResponseModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteUser(String firebaseUid) async {
    await _apiClient.delete(
      ApiConstants.deleteUserEndpoint,
      queryParams: {'firebase_uid': firebaseUid},
    );
  }
}
