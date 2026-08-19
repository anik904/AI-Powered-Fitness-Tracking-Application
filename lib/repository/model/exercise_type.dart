enum ExerciseType { pushup, squat, jumpingJack }

extension ExerciseTypeExtension on ExerciseType {
  String get displayName {
    switch (this) {
      case ExerciseType.pushup:
        return 'Pushups';
      case ExerciseType.squat:
        return 'Squats';
      case ExerciseType.jumpingJack:
        return 'Jumping Jacks';
    }
  }

  String get instruction {
    switch (this) {
      case ExerciseType.pushup:
        return 'Place your phone on the floor in front of you, facing your head. Get into a pushup position with your body straight.';
      case ExerciseType.squat:
        return 'Place phone 2m away facing you. Stand in frame fully.';
      case ExerciseType.jumpingJack:
        return 'Place your phone 2m away facing you. Stand in frame fully. Do jumping jacks with arms overhead and feet apart.';
    }
  }

  String get assetPath {
    switch (this) {
      case ExerciseType.pushup:
        return 'assets/pushup-icon.svg';
      case ExerciseType.squat:
        return 'assets/squats-icon.svg';
      case ExerciseType.jumpingJack:
        return 'assets/jumpingjack-icon.svg';
    }
  }

  static ExerciseType fromString(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('push')) {
      return ExerciseType.pushup;
    } else if (lower.contains('squat')) {
      return ExerciseType.squat;
    } else if (lower.contains('jump') || lower.contains('jack')) {
      return ExerciseType.jumpingJack;
    }
    return ExerciseType.pushup;
  }
}
