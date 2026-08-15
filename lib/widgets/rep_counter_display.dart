import 'package:ai_fitness_tracker/repository/model/exercise_type.dart';
import 'package:ai_fitness_tracker/repository/model/rep_state.dart';
import 'package:flutter/material.dart';


class RepCounterDisplay extends StatefulWidget {
  final int repCount;
  final RepState repState;
  final bool isBodyDetected;
  final ExerciseType? exerciseType;
  final int? totalReps;
  final int? totalTimeSeconds;
  final String? unit; // 'Reps' or 'sec'

  const RepCounterDisplay({
    super.key,
    required this.repCount,
    required this.repState,
    required this.isBodyDetected,
    this.exerciseType,
    this.totalReps,
    this.totalTimeSeconds,
    this.unit,
  });

  @override
  State<RepCounterDisplay> createState() => _RepCounterDisplayState();
}

class _RepCounterDisplayState extends State<RepCounterDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void didUpdateWidget(covariant RepCounterDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repCount > oldWidget.repCount) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unit = (widget.unit ?? '').toLowerCase().trim();
    final isTime = unit == 'sec' || unit == 'seconds';
    final isFixedReps =
        (unit == 'reps' || unit == 'rep') &&
        (widget.totalReps != null && widget.totalReps! >= 1);

    Widget content;
    if (isTime && widget.totalTimeSeconds != null) {
      // Decremental timer
      final remain = (widget.totalTimeSeconds! - widget.repCount).clamp(
        0,
        widget.totalTimeSeconds!,
      );
      final min = remain ~/ 60;
      final sec = remain % 60;
      final timerText =
          '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
      content = Text(
        timerText,
        style: const TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF9800), // Orange
        ),
      );
    } else if (isFixedReps && widget.totalReps != null) {
      // Show current/total, current big and orange, total small and white
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${widget.repCount}',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '/${widget.totalReps}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      // Per rep: just big orange number
      content = Text(
        '${widget.repCount}',
        style: const TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF9800),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final t = _pulseController.value;
        final scale = 1 + (0.08 * (1 - t));
        return Transform.scale(scale: scale, child: content);
      },
    );
  }
}
