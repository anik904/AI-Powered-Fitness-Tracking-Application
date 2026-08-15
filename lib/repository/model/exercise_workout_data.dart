import 'exercise_type.dart';
import 'workout_match_option.dart';

class ExerciseInstructionData {
  final String setupTitle;
  final List<String> setupSteps;
  final String howToTitle;
  final List<String> howToSteps;

  const ExerciseInstructionData({
    required this.setupTitle,
    required this.setupSteps,
    required this.howToTitle,
    required this.howToSteps,
  });
}

const Map<ExerciseType, ExerciseInstructionData> exerciseInstructions = {
  ExerciseType.pushup: ExerciseInstructionData(
    setupTitle: 'Set Up Your Space',
    setupSteps: [
      'Place your phone on a stable surface so your full body stays in frame.',
      'Stand a few steps back and make sure the camera can see your shoulders, hips, and arms.',
      'Keep enough room to lower your chest without leaving the frame.',
    ],
    howToTitle: 'How to Do Push-ups',
    howToSteps: [
      'Start in a straight plank position with your hands under your shoulders.',
      'Lower your body until your chest is close to the floor.',
      'Press back up until your arms are straight again.',
    ],
  ),
  ExerciseType.squat: ExerciseInstructionData(
    setupTitle: 'Set Up Your Squat View',
    setupSteps: [
      'Place your phone about 2 meters away and keep your whole body visible.',
      'Face the camera directly with your feet shoulder-width apart.',
      'Make sure your knees and hips stay visible while you squat.',
    ],
    howToTitle: 'How to Do Squats',
    howToSteps: [
      'Stand tall with your chest up and your core engaged.',
      'Lower your hips back and down like you are sitting into a chair.',
      'Drive through your heels to return to standing.',
    ],
  ),

  ExerciseType.jumpingJack: ExerciseInstructionData(
    setupTitle: 'Set Up Your Jumping Jack View',
    setupSteps: [
      'Place your phone about 2 meters away so your whole body stays visible.',
      'Stand in the center of the frame with enough room to jump sideways.',
      'Keep your arms and legs unobstructed for tracking.',
    ],
    howToTitle: 'How to Do Jumping Jacks',
    howToSteps: [
      'Jump your feet out while raising your arms overhead.',
      'Return to the starting position with control.',
      'Keep a steady rhythm so the camera can track your movement.',
    ],
  ),
};

const Map<ExerciseType, List<WorkoutMatchOption>> exerciseMatchOptions = {
  ExerciseType.pushup: [
    WorkoutMatchOption(reps: 10, minutes: 2, unit: 'Reps'),
    WorkoutMatchOption(reps: 20, minutes: 5, unit: 'Reps'),
    WorkoutMatchOption(reps: 30, minutes: 8, unit: 'Reps'),
  ],
  ExerciseType.squat: [
    WorkoutMatchOption(reps: 10, minutes: 2, unit: 'Reps'),
    WorkoutMatchOption(reps: 20, minutes: 5, unit: 'Reps'),
    WorkoutMatchOption(reps: 30, minutes: 8, unit: 'Reps'),
  ],

  ExerciseType.jumpingJack: [
    WorkoutMatchOption(reps: 25, minutes: 3, unit: 'Reps'),
    WorkoutMatchOption(reps: 50, minutes: 5, unit: 'Reps'),
    WorkoutMatchOption(reps: 75, minutes: 8, unit: 'Reps'),
  ],
};