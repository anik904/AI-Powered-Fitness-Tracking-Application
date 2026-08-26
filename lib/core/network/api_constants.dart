import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String prefCustomUrlKey = 'custom_backend_url';

  // Candidate hosts for auto-probing
  static const List<String> candidateUrls = [
    'http://127.0.0.1:8000',
    'http://10.0.2.2:8000',
    'http://192.168.1.10:8000',
    'http://localhost:8000',
  ];

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://127.0.0.1:8000';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  // Active base URL
  static String baseUrl = defaultBaseUrl;

  // Timeout settings
  static const Duration requestTimeout = Duration(seconds: 12);
  static const Duration probeTimeout = Duration(milliseconds: 1500);

  // Health
  static const String healthEndpoint = '/';

  // Auth endpoints
  static const String registerEndpoint = '/auth/register';
  static const String meEndpoint = '/auth/me';
  static const String deleteUserEndpoint = '/auth/delete';

  // Workout endpoints
  static const String workoutsEndpoint = '/workouts/';
  static const String workoutsBulkEndpoint = '/workouts/bulk';
  static const String workoutsTodayEndpoint = '/workouts/today';
  static const String workoutsClearEndpoint = '/workouts/clear';

  // Goal endpoints
  static const String goalsEndpoint = '/goals/';

  // Challenge endpoints
  static const String challengeEndpoint = '/challenges/';
  static const String challengeStartEndpoint = '/challenges/start';
  static const String challengeResetEndpoint = '/challenges/reset';

  // Sync endpoints
  static const String syncUploadEndpoint = '/sync/upload';
  static const String syncDownloadEndpoint = '/sync/download';

  /// Initialize and resolve active baseUrl on app startup
  static Future<void> initialize([SharedPreferences? prefs]) async {
    final preferences = prefs ?? await SharedPreferences.getInstance();
    final savedUrl = preferences.getString(prefCustomUrlKey);

    if (savedUrl != null && savedUrl.trim().isNotEmpty) {
      baseUrl = savedUrl.trim().replaceAll(RegExp(r'/+$'), '');
      developer.log('Using configured backend URL: $baseUrl', name: 'ApiConstants');
      return;
    }

    // Auto-detect reachable backend
    final workingUrl = await probeReachableHost();
    if (workingUrl != null) {
      baseUrl = workingUrl;
      developer.log('Auto-detected reachable backend URL: $baseUrl', name: 'ApiConstants');
    } else {
      baseUrl = defaultBaseUrl;
      developer.log('No backend responded during probe, using default: $baseUrl', name: 'ApiConstants');
    }
  }

  /// Check if a given URL (or current baseUrl) is responding to health check
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

  /// Probe candidates and return the first responding URL
  static Future<String?> probeReachableHost() async {
    for (final url in candidateUrls) {
      try {
        final res = await http
            .get(Uri.parse('$url$healthEndpoint'))
            .timeout(probeTimeout);
        if (res.statusCode >= 200 && res.statusCode < 300) {
          return url;
        }
      } catch (_) {
        // Candidate not responding, try next
      }
    }
    return null;
  }

  /// Set and persist custom baseUrl
  static Future<void> setBaseUrl(String url, [SharedPreferences? prefs]) async {
    baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    final preferences = prefs ?? await SharedPreferences.getInstance();
    await preferences.setString(prefCustomUrlKey, baseUrl);
    developer.log('Updated backend URL to: $baseUrl', name: 'ApiConstants');
  }

  /// Reset to auto-detected default
  static Future<void> resetBaseUrl([SharedPreferences? prefs]) async {
    final preferences = prefs ?? await SharedPreferences.getInstance();
    await preferences.remove(prefCustomUrlKey);
    await initialize(preferences);
  }
}

