import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../../core/network/api_constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException(status: $statusCode, message: $message)';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$base$cleanPath';

    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      final stringParams = queryParams.map((key, value) => MapEntry(key, value?.toString() ?? ''));
      return uri.replace(queryParameters: stringParams);
    }
    return uri;
  }

  Map<String, String> _defaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final response = await _client
          .get(
            uri,
            headers: {..._defaultHeaders(), if (headers != null) ...headers},
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      developer.log('API GET error on $uri: $e', name: 'ApiClient');
      rethrow;
    }
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParams,
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final response = await _client
          .post(
            uri,
            headers: {..._defaultHeaders(), if (headers != null) ...headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      developer.log('API POST error on $uri: $e', name: 'ApiClient');
      rethrow;
    }
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final response = await _client
          .delete(
            uri,
            headers: {..._defaultHeaders(), if (headers != null) ...headers},
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      developer.log('API DELETE error on $uri: $e', name: 'ApiClient');
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    } else {
      String errorMessage = 'Request failed with status: ${response.statusCode}';
      dynamic errorData;
      try {
        errorData = jsonDecode(response.body);
        if (errorData is Map && errorData.containsKey('detail')) {
          errorMessage = errorData['detail'].toString();
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: errorMessage,
        data: errorData,
      );
    }
  }
}
