import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/database_helper.dart';
import '../../model/api/challenge_api_model.dart';
import '../../model/api/goal_api_model.dart';
import '../../model/api/sync_models.dart';
import '../../model/api/workout_api_model.dart';
import '../../model/exercise_type.dart';
import '../../model/workout_session.dart';
import '../../model/api/user_api_model.dart';
import '../api/auth_api_service.dart';
import '../api/challenge_api_service.dart';
import '../api/goal_api_service.dart';
import '../api/sync_api_service.dart';
import '../api/workout_api_service.dart';

class SyncService {
  final SyncApiService _syncApi;
  final WorkoutApiService _workoutApi;
  final GoalApiService _goalApi;
  final ChallengeApiService _challengeApi;
  final AuthApiService _authApi;

  SyncService({
    SyncApiService? syncApi,
    WorkoutApiService? workoutApi,
    GoalApiService? goalApi,
    ChallengeApiService? challengeApi,
    AuthApiService? authApi,
  })  : _syncApi = syncApi ?? SyncApiService(),
        _workoutApi = workoutApi ?? WorkoutApiService(),
        _goalApi = goalApi ?? GoalApiService(),
        _challengeApi = challengeApi ?? ChallengeApiService(),
        _authApi = authApi ?? AuthApiService();

  static const String lastSyncKey = 'last_sync_timestamp';
  static const String autoSyncKey = 'auto_sync_enabled';

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(lastSyncKey);
    return str != null ? DateTime.tryParse(str) : null;
  }

  Future<void> _recordSyncSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastSyncKey, DateTime.now().toIso8601String());
  }

  Future<bool> isAutoSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(autoSyncKey) ?? true;
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(autoSyncKey, enabled);
  }

  Future<SyncUploadResponse?> uploadLocalState(
    String firebaseUid, {
    String? email,
    String? displayName,
  }) async {
    try {
      if (email != null && email.isNotEmpty) {
        await registerUserOnBackend(
          firebaseUid: firebaseUid,
          email: email,
          displayName: displayName,
        );
      }

      final db = DatabaseHelper.instance;
      final workouts = await db.getAllWorkouts();
      var goals = await db.getAllGoals();
      final prefs = await SharedPreferences.getInstance();

      // Ensure DB has goals before uploading
      if (goals.isEmpty) {
        final pushup = prefs.getInt('pushup_goal') ?? 20;
        final squat = prefs.getInt('squat_goal') ?? 20;
        final jumpingJack = prefs.getInt('jumping_jack_goal') ?? 50;

        await db.saveGoal(ExerciseType.pushup.name, pushup, 'Reps');
        await db.saveGoal(ExerciseType.squat.name, squat, 'Reps');
        await db.saveGoal(ExerciseType.jumpingJack.name, jumpingJack, 'Reps');
        goals = await db.getAllGoals();
      }

      final isChallengeStarted = prefs.getBool('challenge_started') ?? false;
      final challengeStartDateStr = prefs.getString('challenge_start_date');
      final challengeStartDate = challengeStartDateStr != null
          ? DateTime.tryParse(challengeStartDateStr)
          : null;

      final workoutRequests = workouts
          .map(
            (w) => WorkoutCreateRequest(
              exerciseType: w.exerciseType.name,
              reps: w.reps,
              timestamp: w.timestamp,
              clientId: w.clientId,
            ),
          )
          .toList();

      final goalRequests = goals
          .map(
            (g) => GoalCreateRequest(
              exerciseType: g['exerciseType'] as String,
              target: g['target'] as int,
              unit: (g['unit'] as String?) ?? 'Reps',
            ),
          )
          .toList();

      final challengeRequest = isChallengeStarted
          ? ChallengeCreateRequest(
              isStarted: true,
              startDate: challengeStartDate,
            )
          : null;

      final request = SyncUploadRequest(
        workouts: workoutRequests,
        goals: goalRequests,
        challenge: challengeRequest,
      );

      final response = await _syncApi.uploadSync(
        firebaseUid: firebaseUid,
        request: request,
      );

      await _recordSyncSuccess();
      developer.log('Sync upload succeeded: ${response.status}', name: 'SyncService');
      return response;
    } catch (e) {
      developer.log('Background sync upload failed (offline or unreachable): $e', name: 'SyncService');
      return null;
    }
  }

  Future<SyncDownloadResponse?> downloadRemoteState(
    String firebaseUid, {
    bool preserveLocalConflicts = false,
  }) async {
    try {
      final response = await _syncApi.downloadSync(firebaseUid: firebaseUid);
      final db = DatabaseHelper.instance;
      final prefs = await SharedPreferences.getInstance();

      final sessions = response.workouts.map((w) {
        return WorkoutSession(
          exerciseType: ExerciseType.values.firstWhere(
            (e) => e.name == w.exerciseType,
            orElse: () => ExerciseType.pushup,
          ),
          reps: w.reps,
          timestamp: w.timestamp,
          clientId: w.clientId,
        );
      }).toList();
      await db.bulkUpsertWorkouts(sessions);

      int pushup = prefs.getInt('pushup_goal') ?? 20;
      int squat = prefs.getInt('squat_goal') ?? 20;
      int jumpingJack = prefs.getInt('jumping_jack_goal') ?? 50;

      for (final g in response.goals) {
        final existingLocalGoal = await db.getGoal(g.exerciseType);
        if (preserveLocalConflicts && existingLocalGoal != null) {
          continue;
        }

        await db.saveGoal(g.exerciseType, g.target, g.unit);
        if (g.exerciseType == ExerciseType.pushup.name) {
          pushup = g.target;
          await prefs.setInt('pushup_goal', g.target);
        } else if (g.exerciseType == ExerciseType.squat.name) {
          squat = g.target;
          await prefs.setInt('squat_goal', g.target);
        } else if (g.exerciseType == ExerciseType.jumpingJack.name) {
          jumpingJack = g.target;
          await prefs.setInt('jumping_jack_goal', g.target);
        }
      }

      if (response.goals.isNotEmpty && !preserveLocalConflicts) {
        await prefs.setString(
          'user_goal',
          'Push-ups: $pushup, Squats: $squat, Jumping Jacks: $jumpingJack reps/day',
        );
      }

      final localChallengeStarted = prefs.getBool('challenge_started') ?? false;
      if (response.challenge != null) {
        if (!preserveLocalConflicts || !localChallengeStarted) {
          await prefs.setBool('challenge_started', response.challenge!.isStarted);
          if (response.challenge!.startDate != null) {
            await prefs.setString(
              'challenge_start_date',
              response.challenge!.startDate!.toIso8601String(),
            );
          } else {
            await prefs.remove('challenge_start_date');
          }
        }
      }

      await _recordSyncSuccess();
      developer.log('Sync download succeeded', name: 'SyncService');
      return response;
    } catch (e) {
      developer.log('Background sync download failed: $e', name: 'SyncService');
      return null;
    }
  }

  /// Single non-blocking workout sync
  void syncWorkoutInBackground({
    required String? firebaseUid,
    required WorkoutSession session,
  }) {
    if (firebaseUid == null || firebaseUid.isEmpty) return;
    _workoutApi
        .createWorkout(
          firebaseUid: firebaseUid,
          exerciseType: session.exerciseType.name,
          reps: session.reps,
          timestamp: session.timestamp,
          clientId: session.clientId,
        )
        .then((_) {
          _recordSyncSuccess();
          developer.log('Workout synced to backend', name: 'SyncService');
        })
        .catchError((e) {
          developer.log('Workout sync deferred/failed: $e', name: 'SyncService');
        });
  }

  void syncGoalInBackground({
    required String? firebaseUid,
    required String exerciseType,
    required int target,
    String unit = 'Reps',
  }) {
    if (firebaseUid == null || firebaseUid.isEmpty) return;
    _goalApi
        .saveGoal(
          firebaseUid: firebaseUid,
          exerciseType: exerciseType,
          target: target,
          unit: unit,
        )
        .then((_) {
          _recordSyncSuccess();
          developer.log('Goal synced to backend', name: 'SyncService');
        })
        .catchError((e) {
          developer.log('Goal sync deferred/failed: $e', name: 'SyncService');
        });
  }

  void syncChallengeStartInBackground(String? firebaseUid) {
    if (firebaseUid == null || firebaseUid.isEmpty) return;
    _challengeApi
        .startChallenge(firebaseUid: firebaseUid)
        .then((_) {
          _recordSyncSuccess();
          developer.log('Challenge start synced to backend', name: 'SyncService');
        })
        .catchError((e) {
          developer.log('Challenge start sync deferred: $e', name: 'SyncService');
        });
  }

  void syncChallengeResetInBackground(String? firebaseUid) {
    if (firebaseUid == null || firebaseUid.isEmpty) return;
    _challengeApi
        .resetChallenge(firebaseUid: firebaseUid)
        .then((_) {
          _recordSyncSuccess();
          developer.log('Challenge reset synced to backend', name: 'SyncService');
        })
        .catchError((e) {
          developer.log('Challenge reset sync deferred: $e', name: 'SyncService');
        });
  }

  void syncClearWorkoutsInBackground(String? firebaseUid, {DateTime? since}) {
    if (firebaseUid == null || firebaseUid.isEmpty) return;
    _workoutApi
        .clearWorkouts(firebaseUid: firebaseUid, since: since)
        .then((_) {
          _recordSyncSuccess();
          developer.log('Clear workouts synced to backend', name: 'SyncService');
        })
        .catchError((e) {
          developer.log('Clear workouts sync deferred: $e', name: 'SyncService');
        });
  }

  Future<void> registerUserOnBackend({
    required String firebaseUid,
    required String email,
    String? displayName,
  }) async {
    try {
      await _authApi.registerUser(
        firebaseUid: firebaseUid,
        email: email,
        displayName: displayName,
      );
      developer.log('User registered on backend', name: 'SyncService');
    } catch (e) {
      developer.log('Backend user registration error: $e', name: 'SyncService');
    }
  }

  Future<UserResponseModel?> getBackendUser(String firebaseUid) async {
    try {
      final user = await _authApi.getCurrentUser(firebaseUid);
      developer.log('Backend user retrieved: ${user.email}, ${user.displayName}', name: 'SyncService');
      return user;
    } catch (e) {
      developer.log('Backend get user error: $e', name: 'SyncService');
      return null;
    }
  }

  Future<void> deleteUserFromBackend(String firebaseUid) async {
    try {
      await _authApi.deleteUser(firebaseUid);
      developer.log('User deleted from backend', name: 'SyncService');
    } catch (e) {
      developer.log('Backend delete user error: $e', name: 'SyncService');
    }
  }

  Future<void> clearOnlineUserData(String firebaseUid) async {
    try {
      await _workoutApi.clearWorkouts(firebaseUid: firebaseUid);
      await _challengeApi.resetChallenge(firebaseUid: firebaseUid);
      developer.log('Online user data cleared on backend', name: 'SyncService');
    } catch (e) {
      developer.log('Failed to clear online user data on backend: $e', name: 'SyncService');
    }
  }
}
