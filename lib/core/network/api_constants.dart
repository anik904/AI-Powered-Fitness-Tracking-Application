import 'dart:async';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String baseUrl = 'http://192.168.1.164:8000';

  static const Duration requestTimeout = Duration(seconds: 20);

  static const String healthEndpoint = '/';

  static const String registerEndpoint = '/auth/register';
  static const String meEndpoint = '/auth/me';
  static const String deleteUserEndpoint = '/auth/delete';

  static const String workoutsEndpoint = '/workouts/';
  static const String workoutsBulkEndpoint = '/workouts/bulk';
  static const String workoutsTodayEndpoint = '/workouts/today';
  static const String workoutsClearEndpoint = '/workouts/clear';

  static const String goalsEndpoint = '/goals/';

  static const String challengeEndpoint = '/challenges/';
  static const String challengeStartEndpoint = '/challenges/start';
  static const String challengeResetEndpoint = '/challenges/reset';

  static const String syncUploadEndpoint = '/sync/upload';
  static const String syncDownloadEndpoint = '/sync/download';

  // Initialize active baseUrl on app startup
  static Future<void> initialize([SharedPreferences? prefs]) async {
    developer.log('Backend URL initialized: $baseUrl', name: 'ApiConstants');
  }

  static Future<bool> testConnection([String? testUrl]) async {
    final target = (testUrl ?? baseUrl).replaceAll(RegExp(r'/+$'), '');
    try {
      final res = await http
          .get(Uri.parse('$target$healthEndpoint'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
