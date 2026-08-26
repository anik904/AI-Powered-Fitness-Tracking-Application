import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repository/services/sync/sync_service.dart';
import '../providers/shared_preferences_provider.dart';

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
    // Save to SharedPreferences for display
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('user_name', user.displayName ?? user.email?.split('@').first ?? 'User');
      await prefs.setString('user_email', user.email ?? '');
    } catch (_) {}

    // Register on backend in background
    try {
      await _syncService.registerUserOnBackend(
        firebaseUid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );

      // Perform initial background sync
      unawaited(_syncService.uploadLocalState(
        user.uid,
        email: user.email,
        displayName: user.displayName,
      ));
    } catch (e) {
      developer.log('Post-auth background sync error: $e', name: 'AuthNotifier');
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

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
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
