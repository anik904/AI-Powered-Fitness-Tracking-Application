import 'package:ai_fitness_tracker/repository/model/exercise_type.dart';
import 'package:ai_fitness_tracker/repository/model/exercise_workout_data.dart';
import 'package:ai_fitness_tracker/repository/model/workout_match_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/services/sync/sync_service.dart';
import '../database/database_helper.dart';
import '../providers/shared_preferences_provider.dart';
import 'auth_provider.dart';

class ExerciseCardData {
  final String title;
  final Color badgeColor;
  final Color iconBg;
  final IconData icon;
  final ExerciseType routeType;

  const ExerciseCardData({
    required this.title,
    required this.badgeColor,
    required this.iconBg,
    required this.icon,
    required this.routeType,
  });
}

class ExerciseGoal {
  final ExerciseCardData cardData;
  final int target;
  final String unit;
  final WorkoutMatchOption matchOption;
  ExerciseGoal({
    required this.cardData,
    required this.target,
    required this.unit,
    required this.matchOption,
  });

  ExerciseGoal copyWith({
    int? target,
    String? unit,
    WorkoutMatchOption? matchOption,
  }) => ExerciseGoal(
    cardData: cardData,
    target: target ?? this.target,
    unit: unit ?? this.unit,
    matchOption: matchOption ?? this.matchOption,
  );
}

class ExerciseGoalNotifier extends Notifier<List<ExerciseGoal>> {
  final SyncService _syncService = SyncService();

  @override
  List<ExerciseGoal> build() {
    final initial = [
      ExerciseGoal(
        cardData: const ExerciseCardData(
          title: 'Pushups',
          badgeColor: Color(0xFFB6F23A),
          iconBg: Color(0xFF192615),
          icon: Icons.fitness_center,
          routeType: ExerciseType.pushup,
        ),
        target: 20,
        unit: 'Reps',
        matchOption: exerciseMatchOptions[ExerciseType.pushup]!.firstWhere(
          (o) => o.reps == 20,
          orElse: () => exerciseMatchOptions[ExerciseType.pushup]!.first,
        ),
      ),
      ExerciseGoal(
        cardData: const ExerciseCardData(
          title: 'Squats',
          badgeColor: Color(0xFF66E8FF),
          iconBg: Color(0xFF15303D),
          icon: Icons.downhill_skiing,
          routeType: ExerciseType.squat,
        ),
        target: 20,
        unit: 'Reps',
        matchOption: exerciseMatchOptions[ExerciseType.squat]!.firstWhere(
          (o) => o.reps == 20,
          orElse: () => exerciseMatchOptions[ExerciseType.squat]!.first,
        ),
      ),
      ExerciseGoal(
        cardData: const ExerciseCardData(
          title: 'Jumping Jacks',
          badgeColor: Color(0xFFB388FF),
          iconBg: Color(0xFF2E1A47),
          icon: Icons.directions_run,
          routeType: ExerciseType.jumpingJack,
        ),
        target: 50,
        unit: 'Reps',
        matchOption: exerciseMatchOptions[ExerciseType.jumpingJack]!.firstWhere(
          (o) => o.reps == 50,
          orElse: () => exerciseMatchOptions[ExerciseType.jumpingJack]!.first,
        ),
      ),
    ];
    
    Future.microtask(() => reloadFromDb());

    return initial;
  }

  String _prefKeyForType(ExerciseType type) {
    if (type == ExerciseType.jumpingJack) return 'jumping_jack_goal';
    return '${type.name}_goal';
  }

  Future<void> reloadFromDb() async {
    final db = DatabaseHelper.instance;
    final goals = List<ExerciseGoal>.from(state);
    final prefs = ref.read(sharedPreferencesProvider);
    
    for (int i = 0; i < goals.length; i++) {
      final routeType = goals[i].cardData.routeType;
      final typeName = routeType.name;
      final goalData = await db.getGoal(typeName);

      int target;
      String unit = 'Reps';

      if (goalData != null) {
        target = goalData['target'] as int;
        unit = (goalData['unit'] as String?) ?? 'Reps';
      } else {
        final prefKey = _prefKeyForType(routeType);
        target = prefs.getInt(prefKey) ?? goals[i].target;
        await db.saveGoal(typeName, target, unit);
      }

      // Keep SharedPreferences in sync
      final prefKey = _prefKeyForType(routeType);
      await prefs.setInt(prefKey, target);

      goals[i] = goals[i].copyWith(
        target: target,
        unit: unit,
        matchOption: WorkoutMatchOption(
          reps: target,
          minutes: 0,
          unit: unit,
        ),
      );
    }
    state = goals;
  }

  void updateGoal(int index, {int? target, String? unit, WorkoutMatchOption? matchOption}) {
    final oldGoal = state[index];
    final newTarget = target ?? oldGoal.target;
    final newUnit = unit ?? oldGoal.unit;
    final newOption = matchOption ?? WorkoutMatchOption(
      reps: newTarget,
      minutes: 0,
      unit: newUnit,
    );

    final newGoal = oldGoal.copyWith(
      target: newTarget,
      unit: newUnit,
      matchOption: newOption,
    );

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) newGoal else state[i],
    ];

    // Save to DB locally
    DatabaseHelper.instance.saveGoal(
      newGoal.cardData.routeType.name,
      newGoal.target,
      newGoal.unit,
    );

    // update SharedPreferences
    final prefs = ref.read(sharedPreferencesProvider);
    final prefKey = _prefKeyForType(newGoal.cardData.routeType);
    prefs.setInt(prefKey, newGoal.target);

    // Non-blocking background sync
    final user = ref.read(authProvider).user;
    if (user != null) {
      _syncService.syncGoalInBackground(
        firebaseUid: user.uid,
        exerciseType: newGoal.cardData.routeType.name,
        target: newGoal.target,
        unit: newGoal.unit,
      );
    }
  }

  void updateGoalByType(ExerciseType type, {required int target, String unit = 'Reps'}) {
    final index = state.indexWhere((goal) => goal.cardData.routeType == type);
    if (index == -1) {
      return;
    }

    final options = exerciseMatchOptions[type];
    final selectedOption = options?.firstWhere(
      (option) => option.reps == target,
      orElse: () => WorkoutMatchOption(reps: target, minutes: 0, unit: unit),
    );

    updateGoal(
      index,
      target: target,
      unit: unit,
      matchOption: selectedOption,
    );
  }
}

final exerciseGoalProvider = NotifierProvider<ExerciseGoalNotifier, List<ExerciseGoal>>(() => ExerciseGoalNotifier());
