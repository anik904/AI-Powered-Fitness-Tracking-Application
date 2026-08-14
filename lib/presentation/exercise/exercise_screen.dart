// import 'package:camera/camera.dart';
import 'package:ai_fitness_tracker/core/provider/exercise_provider.dart';
import 'package:ai_fitness_tracker/presentation/exercise/exercise_camera.dart';
import 'package:ai_fitness_tracker/presentation/exercise/widgets/exercise_info_sheet.dart';
import 'package:ai_fitness_tracker/presentation/exercise/widgets/congratulations_bottom_sheet.dart';
import 'package:ai_fitness_tracker/widgets/pose_overlay_painter.dart';
import 'package:ai_fitness_tracker/widgets/rep_counter_display.dart';
import 'package:ai_fitness_tracker/repository/model/exercise_type.dart';
import 'package:ai_fitness_tracker/repository/model/workout_match_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';


class ExerciseScreen extends ConsumerStatefulWidget {
  final ExerciseType exerciseType;
  final WorkoutMatchOption sessionOption;

  const ExerciseScreen({
    super.key,
    required this.exerciseType,
    required this.sessionOption,
  });

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  static const double _topOverlayMargin = 8;
  static const double _topControlHeight = 44;
  static const double _topRowBottomPadding = 8;
  static const double _warningGapFromTopRow = 24;

  // FIX 5: Guard so we never act on isComplete before initialize() has run.
  bool _providerInitialized = false;

  bool _completionShown = false;

  double _floatingTopRowTop(BuildContext context) {
    return MediaQuery.of(context).viewPadding.top + _topOverlayMargin;
  }

  double _warningTop(BuildContext context) {
    return _floatingTopRowTop(context) +
        _topControlHeight +
        _topRowBottomPadding +
        _warningGapFromTopRow +
        24;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(exerciseProvider.notifier)
          .initialize(widget.exerciseType, sessionOption: widget.sessionOption);
      if (mounted) setState(() => _providerInitialized = true);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseProvider);
    if (_providerInitialized && state.isComplete && !_completionShown) {
      _completionShown = true;
      Future.microtask(() {
        if (!mounted) return;
        _onExerciseFinished();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1520),
      body: Stack(
        children: [
          _buildMainLayout(context, state),
          _buildTopBar(context, state),
          if (!state.isSetupValid) _buildSetupWarning(state),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Main layout: camera card (rep counter inside) + compact bottom action bar
  // ---------------------------------------------------------------------------
  Widget _buildMainLayout(BuildContext context, ExerciseState state) {
    final topPadding = MediaQuery.of(context).viewPadding.top;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    final topBarHeight =
        topPadding +
        _topOverlayMargin +
        _topControlHeight +
        _topRowBottomPadding;

    return Column(
      children: [
        SizedBox(height: topBarHeight + 24),
        // ── Camera card — rep counter lives INSIDE ────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _buildCameraCard(state),
          ),
        ),

        const SizedBox(height: 24),

        // ── Compact bottom action bar ─────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset),
          child: _buildPrimaryActionButton(state),
        ),
      ],
    );
  }

  Widget _buildCameraCard(ExerciseState state) {
    final notifier = ref.read(exerciseProvider.notifier);
    final unit = (state.sessionOption?.unit ?? '').toLowerCase().trim();
    final isTime = unit == 'sec' || unit == 'seconds';
    final isReps = unit == 'reps' || unit == 'rep';
    final totalReps = isTime
        ? null
        : (isReps && (state.sessionOption?.reps != 1)
              ? state.sessionOption?.reps
              : null);
    final totalTimeSeconds = isTime ? state.sessionOption?.reps : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExerciseCamera(
            onImage: notifier.processFrame,
            lensDirection: CameraLensDirection.front,
            overlayBuilder: (context, imageSize) {
              return CustomPaint(
                painter: PoseOverlayPainter(
                  poses: state.currentPoses,
                  imageSize: imageSize,
                  isFrontCamera: true,
                ),
              );
            },
          ),
          // Counter at the bottom center
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: RepCounterDisplay(
                repCount: state.repCount,
                repState: state.repState,
                isBodyDetected: state.isBodyDetected,
                exerciseType: state.exerciseType,
                totalReps: totalReps,
                totalTimeSeconds: totalTimeSeconds,
                unit: unit,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Removed unused _buildCameraContent method

  // ---------------------------------------------------------------------------
  // Top bar
  // ---------------------------------------------------------------------------
  Widget _buildTopBar(BuildContext context, ExerciseState state) {
    return Positioned(
      top: _floatingTopRowTop(context),
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        child: Row(
          children: [
            _buildTopIconButton(
              icon: Icons.close,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            Expanded(child: Center(child: _buildExercisePill())),
            const SizedBox(width: 12),
            _buildTopIconButton(
              icon: Icons.info_outline,
              onPressed: () =>
                  showExerciseInfoSheet(context, widget.exerciseType, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: const Color(0xA61B2546),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      ),
    );
  }

  Widget _buildExercisePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xE61F2B4A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.fitness_center_rounded,
            color: Colors.white70,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            widget.exerciseType.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Compact finish button
  // ---------------------------------------------------------------------------
  Widget _buildPrimaryActionButton(ExerciseState state) {
    final hasReps = state.repCount > 0;
    final label = hasReps ? 'Finish' : 'Cancel';

    void onPressed() {
      if (hasReps) {
        _completionShown = true;
        _onExerciseFinished();
      } else {
        Navigator.pop(context);
      }
    }

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
              //hasReps
              // ?
              const LinearGradient(
                colors: [
                  Color.fromARGB(255, 95, 151, 255),
                  Color.fromARGB(255, 141, 204, 255),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
          //: null,
          borderRadius: BorderRadius.circular(32),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Setup warning
  // ---------------------------------------------------------------------------
  Widget _buildSetupWarning(ExerciseState state) {
    final warningText = !state.isBodyDetected
        ? 'Body not found. Move fully into frame.'
        : 'Pose not correct. ${widget.exerciseType.instruction}';

    return Positioned(
      top: _warningTop(context),
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF262939).withOpacity(0.88),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          warningText,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Finish Logic
  // ---------------------------------------------------------------------------
  void _onExerciseFinished() {
    showCongratulationsBottomSheet(
      context: context,
      onContinue: () => Navigator.pop(context),
    );
  }
}
