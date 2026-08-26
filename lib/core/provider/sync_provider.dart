import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repository/services/sync/sync_service.dart';
import 'auth_provider.dart';
import 'exercise_goal_provider.dart';
import 'workout_provider.dart';

class SyncUIState {
  final DateTime? lastSyncTime;
  final bool isSyncing;
  final bool autoSyncEnabled;
  final String? syncMessage;

  const SyncUIState({
    this.lastSyncTime,
    this.isSyncing = false,
    this.autoSyncEnabled = true,
    this.syncMessage,
  });

  String get formattedLastSync {
    if (lastSyncTime == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastSyncTime!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays == 0 && now.day == lastSyncTime!.day) {
      final hour = lastSyncTime!.hour % 12 == 0 ? 12 : lastSyncTime!.hour % 12;
      final minute = lastSyncTime!.minute.toString().padLeft(2, '0');
      final period = lastSyncTime!.hour >= 12 ? 'PM' : 'AM';
      return 'Today, $hour:$minute $period';
    } else {
      final hour = lastSyncTime!.hour % 12 == 0 ? 12 : lastSyncTime!.hour % 12;
      final minute = lastSyncTime!.minute.toString().padLeft(2, '0');
      final period = lastSyncTime!.hour >= 12 ? 'PM' : 'AM';
      return '${lastSyncTime!.day}/${lastSyncTime!.month}, $hour:$minute $period';
    }
  }

  SyncUIState copyWith({
    DateTime? lastSyncTime,
    bool? isSyncing,
    bool? autoSyncEnabled,
    String? syncMessage,
  }) {
    return SyncUIState(
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isSyncing: isSyncing ?? this.isSyncing,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncMessage: syncMessage ?? this.syncMessage,
    );
  }
}

class SyncNotifier extends Notifier<SyncUIState> {
  final SyncService _syncService = SyncService();

  @override
  SyncUIState build() {
    Future.microtask(() => _loadInitialState());
    return const SyncUIState();
  }

  Future<void> _loadInitialState() async {
    final lastTime = await _syncService.getLastSyncTime();
    final autoSync = await _syncService.isAutoSyncEnabled();
    state = state.copyWith(
      lastSyncTime: lastTime,
      autoSyncEnabled: autoSync,
    );
  }

  Future<void> toggleAutoSync(bool enabled) async {
    await _syncService.setAutoSyncEnabled(enabled);
    state = state.copyWith(autoSyncEnabled: enabled);
  }

  Future<void> syncNow() async {
    final auth = ref.read(authProvider);
    if (!auth.isSignedIn || auth.uid == null) {
      state = state.copyWith(syncMessage: 'Please sign in to sync');
      return;
    }

    state = state.copyWith(isSyncing: true, syncMessage: null);

    try {
      final uploadRes = await _syncService.uploadLocalState(
        auth.uid!,
        email: auth.email,
        displayName: auth.displayName,
      );
      final now = DateTime.now();
      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: now,
        syncMessage: uploadRes != null ? 'Sync successful' : 'Offline. Data saved locally.',
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        syncMessage: 'Sync deferred: saved locally.',
      );
    }
  }

  Future<void> restoreFromCloud() async {
    final auth = ref.read(authProvider);
    if (!auth.isSignedIn || auth.uid == null) return;

    state = state.copyWith(isSyncing: true);
    try {
      await _syncService.downloadRemoteState(auth.uid!);
      // Refresh local providers
      await ref.read(workoutProvider.notifier).loadRecentWorkouts();
      await ref.read(exerciseGoalProvider.notifier).reloadFromDb();
      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        syncMessage: 'Data restored successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        syncMessage: 'Restore failed: working offline',
      );
    }
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncUIState>(() {
  return SyncNotifier();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});
