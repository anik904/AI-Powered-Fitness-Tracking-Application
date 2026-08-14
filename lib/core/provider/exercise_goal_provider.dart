import 'package:ai_fitness_tracker/repository/model/exercise_type.dart';
import 'package:ai_fitness_tracker/repository/model/exercise_workout_data.dart';
import 'package:ai_fitness_tracker/repository/model/workout_match_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


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
  final String unit; // 'Reps' or 'min'
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
  @override
  List<ExerciseGoal> build() {
    final initial = [
      // Default goals - choose a sensible default match option from the options map
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
          title: 'Planks',
          badgeColor: Color(0xFFFFD600),
          iconBg: Color(0xFF2B2B15),
          icon: Icons.timer,
          routeType: ExerciseType.plank,
        ),
        target: 1, // default target in minutes for planks (1 min)
        unit: 'min',
        matchOption: exerciseMatchOptions[ExerciseType.plank]!.firstWhere(
          (o) => o.reps == 60,
          orElse: () => exerciseMatchOptions[ExerciseType.plank]!.first,
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

    return initial;
  }

  void updateGoal(int index, {int? target, String? unit, WorkoutMatchOption? matchOption}) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          // Always enforce correct units: Planks = min, Squats = Reps
          state[i].cardData.routeType == ExerciseType.plank
              ? state[i].copyWith(
                  target: target,
                  unit: 'min',
                  matchOption: matchOption ?? WorkoutMatchOption(reps: 0, minutes: (target ?? state[i].target).toDouble(), unit: 'min'),
                )
              : state[i].cardData.routeType == ExerciseType.squat
                  ? state[i].copyWith(
                      target: target,
                      unit: 'Reps',
                      matchOption: matchOption ?? WorkoutMatchOption(reps: (target ?? state[i].target), minutes: 0, unit: 'Reps'),
                    )
                  : state[i].copyWith(
                      target: target,
                      unit: unit,
                      matchOption: matchOption,
                    )
        else
          state[i],
    ];
  }
}

final exerciseGoalProvider = NotifierProvider<ExerciseGoalNotifier, List<ExerciseGoal>>(() => ExerciseGoalNotifier());
