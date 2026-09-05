import 'package:ai_fitness_tracker/core/provider/exercise_provider.dart';
import 'package:ai_fitness_tracker/repository/model/exercise_type.dart';
import 'package:ai_fitness_tracker/widgets/exercise_icon_widget.dart';
import 'package:flutter/material.dart';


Future<void> showExerciseInfoSheet(BuildContext context, ExerciseType exerciseType, ExerciseState state) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExerciseIconWidget(
                exerciseType: exerciseType,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                exerciseType.displayName,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 16),
          Text(
            exerciseType.instruction,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    ),
  );
}
