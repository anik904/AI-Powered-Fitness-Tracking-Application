import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final currentUser = FirebaseAuth.instance.currentUser;

    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
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

  Future<void> _onUserAuthenticated(User user) async {
    // 1. Save user profile info for display
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final onboardingName = prefs.getString('onboarding_name');
      final existingName = prefs.getString('user_name');
      
      if (onboardingName != null && onboardingName.trim().isNotEmpty) {
        await prefs.setString('user_name', onboardingName.trim());
      } else if (existingName == null || existingName.trim().isEmpty || existingName == 'User' || existingName == 'Guest User') {
        final fallbackName = user.displayName ?? user.email?.split('@').first ?? 'User';
        await prefs.setString('user_name', fallbackName);
      }
      await prefs.setString('user_email', user.email ?? '');
    } catch (_) {}

    // 2. Register on backend in background
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final displayName = prefs.getString('onboarding_name') ?? prefs.getString('user_name') ?? user.displayName;

      await _syncService.registerUserOnBackend(
        firebaseUid: user.uid,
        email: user.email ?? '',
        displayName: displayName,
      );
    } catch (e) {
      developer.log('Post-auth backend registration error: $e', name: 'AuthNotifier');
    }

    // 3. Clear previous local cache and download this user's cloud data
    try {
      await DatabaseHelper.instance.clearAllData();
      final downloadRes = await _syncService.downloadRemoteState(user.uid);
      if (downloadRes != null) {
        developer.log('Successfully synced ${downloadRes.workouts.length} workouts and ${downloadRes.goals.length} goals from cloud for user ${user.uid}', name: 'AuthNotifier');
      }
    } catch (e) {
      developer.log('Post-auth download remote state error: $e', name: 'AuthNotifier');
    }

    // 4. Refresh local providers with newly downloaded data
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
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(user: credential.user, isLoading: false);
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
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
      state = state.copyWith(user: credential.user, isLoading: false);
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

      // Clear local database to prevent data leaking between user accounts
      await DatabaseHelper.instance.clearAllData();

      // Clear user-specific preferences
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('challenge_started');
      await prefs.remove('challenge_start_date');

      // Reload providers
      await ref.read(workoutProvider.notifier).loadRecentWorkouts();
      await ref.read(exerciseGoalProvider.notifier).reloadFromDb();
      ref.read(challengeProvider.notifier).reloadFromPrefs();

      state = const UserAuthState();
    } catch (e) {
      developer.log('Sign out error: $e', name: 'AuthNotifier');
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
