import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repository/model/exercise_type.dart';
import '../../repository/services/sync/sync_service.dart';
import '../database/database_helper.dart';
import '../providers/shared_preferences_provider.dart';
import 'challenge_provider.dart';
import 'exercise_goal_provider.dart';
import 'workout_provider.dart';

class UserAuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const UserAuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isSignedIn => user != null;
  String? get uid => user?.uid;
  String? get email => user?.email;
  String get displayName => user?.displayName ?? email?.split('@').first ?? 'User';

  UserAuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
  }) {
    return UserAuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<UserAuthState> {
  StreamSubscription<User?>? _authSubscription;
  late final SyncService _syncService;

  @override
  UserAuthState build() {
    _syncService = SyncService();

    final prefs = ref.read(sharedPreferencesProvider);
    final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
    final isGuest = prefs.getBool('is_guest_mode') ?? false;

    // If guest mode is active or onboarding not yet completed, clear session
    if ((!hasCompletedOnboarding || isGuest) && FirebaseAuth.instance.currentUser != null) {
      FirebaseAuth.instance.signOut();
    }

    final currentUser = (!hasCompletedOnboarding || isGuest) ? null : FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      Future.microtask(() => _onUserAuthenticated(currentUser));
    }

    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      final currentPrefs = ref.read(sharedPreferencesProvider);
      final currentHasCompleted = currentPrefs.getBool('has_completed_onboarding') ?? false;
      final currentIsGuest = currentPrefs.getBool('is_guest_mode') ?? false;

      if (!currentHasCompleted || currentIsGuest) {
        state = const UserAuthState();
        return;
      }

      state = state.copyWith(user: user, clearUser: user == null);
      if (user != null) {
        _onUserAuthenticated(user);
      }
    });

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return UserAuthState(user: currentUser);
  }

  Future<void> refreshUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _onUserAuthenticated(user);
    }
  }

  Future<void> _onUserAuthenticated(User user) async {
    // Save user profile info for display
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('is_guest_mode', false);

      // Fetch user profile from backend to get saved display name if available
      String? backendName;
      try {
        final backendUser = await _syncService.getBackendUser(user.uid);
        if (backendUser != null && backendUser.displayName != null && backendUser.displayName!.trim().isNotEmpty) {
          backendName = backendUser.displayName!.trim();
        }
      } catch (_) {}

      final onboardingName = prefs.getString('onboarding_name');
      final existingName = prefs.getString('user_name');
      
      final String resolvedName;
      if (backendName != null && backendName.isNotEmpty) {
        resolvedName = backendName;
      } else if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        resolvedName = user.displayName!.trim();
      } else if (onboardingName != null && onboardingName.trim().isNotEmpty && onboardingName != 'Guest User' && onboardingName != 'User') {
        resolvedName = onboardingName.trim();
      } else if (existingName != null && existingName.trim().isNotEmpty && existingName != 'User' && existingName != 'Guest User') {
        resolvedName = existingName.trim();
      } else {
        resolvedName = user.email?.split('@').first ?? 'User';
      }

      await prefs.setString('user_name', resolvedName);
      await prefs.setString('user_email', user.email ?? '');

      // Ensure state is updated so listeners react immediately
      state = state.copyWith(user: user);
    } catch (e) {
      developer.log('Error saving user profile info: $e', name: 'AuthNotifier');
    }

    // Register on backend in background
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final displayName = prefs.getString('user_name') ?? user.displayName;

      await _syncService.registerUserOnBackend(
        firebaseUid: user.uid,
        email: user.email ?? '',
        displayName: displayName,
      );
    } catch (e) {
      developer.log('Post-auth backend registration error: $e', name: 'AuthNotifier');
    }

    // Ensure local guest goals exist in database and upload guest state to cloud
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final db = DatabaseHelper.instance;

      // Ensure all goals from state or SharedPreferences are saved in DB
      final currentGoals = ref.read(exerciseGoalProvider);
      for (final goal in currentGoals) {
        final existingGoal = await db.getGoal(goal.cardData.routeType.name);
        if (existingGoal == null) {
          final prefKey = goal.cardData.routeType == ExerciseType.jumpingJack
              ? 'jumping_jack_goal'
              : '${goal.cardData.routeType.name}_goal';
          final target = prefs.getInt(prefKey) ?? goal.target;
          await db.saveGoal(goal.cardData.routeType.name, target, goal.unit);
        }
      }

      // Upload local guest data (goals, workouts, challenge state) to the cloud for this user
      final displayName = prefs.getString('user_name') ?? user.displayName;
      await _syncService.uploadLocalState(
        user.uid,
        email: user.email,
        displayName: displayName,
      );
    } catch (e) {
      developer.log('Post-auth upload local state error: $e', name: 'AuthNotifier');
    }

    // Download remote state and merge into local database
    try {
      final downloadRes = await _syncService.downloadRemoteState(
        user.uid,
        preserveLocalConflicts: true,
      );
      if (downloadRes != null) {
        developer.log('Successfully synced ${downloadRes.workouts.length} workouts and ${downloadRes.goals.length} goals from cloud for user ${user.uid}', name: 'AuthNotifier');
      }
    } catch (e) {
      developer.log('Post-auth download remote state error: $e', name: 'AuthNotifier');
    }

    // Refresh local providers with newly synced data
    try {
      await ref.read(workoutProvider.notifier).loadRecentWorkouts();
      await ref.read(exerciseGoalProvider.notifier).reloadFromDb();
      ref.read(challengeProvider.notifier).reloadFromPrefs();
    } catch (e) {
      developer.log('Post-auth reload providers error: $e', name: 'AuthNotifier');
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('is_guest_mode', false);
      await prefs.setBool('has_completed_onboarding', true);

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await _onUserAuthenticated(user);
      }
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Login failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({required String email, required String password, String? displayName}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Clear guest mode first
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('is_guest_mode', false);
      await prefs.setBool('has_completed_onboarding', true);

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
      final user = credential.user;
      if (user != null) {
        await _onUserAuthenticated(user);
      }
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Registration failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Password reset failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      state = state.copyWith(error: 'User not signed in');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await currentUser.updatePassword(newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Password update failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Clear local database
      await DatabaseHelper.instance.clearAllData();

      // Clear all SharedPreferences
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.clear();

      // Reset onboarding state provider
      ref.read(onboardingStatusProvider.notifier).state = false;

      // Reload all providers to clean state
      await ref.read(workoutProvider.notifier).loadRecentWorkouts();
      await ref.read(exerciseGoalProvider.notifier).reloadFromDb();
      ref.read(challengeProvider.notifier).reloadFromPrefs();

      state = const UserAuthState();
    } catch (e) {
      developer.log('Sign out error: $e', name: 'AuthNotifier');
    }
  }

  Future<void> deleteAllUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;
    final prefs = ref.read(sharedPreferencesProvider);
    final isGuest = (currentUser == null) || (prefs.getBool('is_guest_mode') ?? false);

    if (uid != null && !isGuest) {
      // Clear online workouts and challenge data on backend
      try {
        await _syncService.clearOnlineUserData(uid);
      } catch (e) {
        developer.log('Clear online data error: $e', name: 'AuthNotifier');
      }

      // Clear local database (workouts and goals)
      await DatabaseHelper.instance.clearAllData();

      // Clear fitness-related SharedPreferences while keeping user session & onboarding status
      await prefs.remove('challenge_started');
      await prefs.remove('challenge_start_date');
      await prefs.remove('last_sync_timestamp');
      await prefs.remove('pushup_goal');
      await prefs.remove('squat_goal');
      await prefs.remove('jumping_jack_goal');
      await prefs.remove('user_goal');

      // Reload all providers to clean state
      await ref.read(workoutProvider.notifier).loadRecentWorkouts();
      await ref.read(exerciseGoalProvider.notifier).reloadFromDb();
      ref.read(challengeProvider.notifier).reloadFromPrefs();
    } else {
      // Guest mode: wipe all local data, preferences, reset onboarding state, and signOut
      await signOut();
    }
  }

  Future<bool> deleteAccount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final uid = currentUser.uid;
    try {
      // Delete on backend
      await _syncService.deleteUserFromBackend(uid);
      // Delete on Firebase
      await currentUser.delete();
      await DatabaseHelper.instance.clearAllData();
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.clear();
      ref.read(onboardingStatusProvider.notifier).state = false;
      state = const UserAuthState();
      return true;
    } catch (e) {
      developer.log('Delete account error: $e', name: 'AuthNotifier');
      return false;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserAuthState>(() {
  return AuthNotifier();
});
