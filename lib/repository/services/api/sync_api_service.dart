import '../../../core/network/api_constants.dart';
import '../../model/api/sync_models.dart';
import 'api_client.dart';

class SyncApiService {
  final ApiClient _apiClient;

  SyncApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<SyncUploadResponse> uploadSync({
    required String firebaseUid,
    required SyncUploadRequest request,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.syncUploadEndpoint,
      queryParams: {'firebase_uid': firebaseUid},
      body: request.toJson(),
    );

    return SyncUploadResponse.fromJson(response as Map<String, dynamic>);
  }

  Future<SyncDownloadResponse> downloadSync({
    required String firebaseUid,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.syncDownloadEndpoint,
      queryParams: {'firebase_uid': firebaseUid},
    );

    return SyncDownloadResponse.fromJson(response as Map<String, dynamic>);
  }
}
