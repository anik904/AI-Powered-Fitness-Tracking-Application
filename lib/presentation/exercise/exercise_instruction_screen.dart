import 'package:ai_fitness_tracker/repository/model/exercise_workout_data.dart';
import 'package:ai_fitness_tracker/repository/model/exercise_type.dart';
import 'package:ai_fitness_tracker/repository/model/workout_match_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'exercise_screen.dart';

/// Two-step instruction screen shown before starting the exercise.
///
/// Step 0 → Phone placement instructions (setupTitle + setupSteps)
/// Step 1 → How-to-do-it instructions  (howToTitle + howToSteps)
///
/// After both steps the exercise screen is pushed.
class ExerciseInstructionScreen extends StatefulWidget {
  final ExerciseType exerciseType;
  final WorkoutMatchOption sessionOption;

  const ExerciseInstructionScreen({
    super.key,
    required this.exerciseType,
    required this.sessionOption,
  });

  @override
  State<ExerciseInstructionScreen> createState() =>
      _ExerciseInstructionScreenState();
}

class _ExerciseInstructionScreenState extends State<ExerciseInstructionScreen>
    with SingleTickerProviderStateMixin {
  late final ExerciseInstructionData _data;
  int _currentStep = 0; // 0 = setup, 1 = how-to

  // Animation
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Force dark status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _data = exerciseInstructions[widget.exerciseType]!;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.value = 1.0; // start fully visible
  }



  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_currentStep == 0) {
      // Animate transition to step 1
      _fadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() => _currentStep = 1);
        _fadeController.forward();
      });
    } else {
      // Navigate to exercise screen
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseScreen(
            exerciseType: widget.exerciseType,
            sessionOption: widget.sessionOption,
          ),
        ),
      ).then((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1520),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            // ── Top bar ──────────────────────────────────────────────
            _buildTopBar(),
            const SizedBox(height: 16),

            // ── Title + steps (animated) ─────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildInstructionContent(),
              ),
            ),

            // ── Continue button ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset + 16),
              child: _buildContinueButton(),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Top Bar
  // ─────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _buildTopIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: () => Navigator.pop(context, 0.0),
          ),
          const Spacer(),
          // Step indicator
          Row(
            children: List.generate(2, (i) {
              final isActive = i == _currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? const Color(0xFF6B9FFF)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              );
            }),
          ),
          const Spacer(),
          // Balance the back button
          const SizedBox(width: 44),
        ],
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

  // ─────────────────────────────────────────────────────────────
  // Instruction Content
  // ─────────────────────────────────────────────────────────────
  Widget _buildInstructionContent() {
    final title = _currentStep == 0 ? _data.setupTitle : _data.howToTitle;
    final steps = _currentStep == 0 ? _data.setupSteps : _data.howToSteps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            // Subtitle
            Text(
              _currentStep == 0
                  ? widget.exerciseType.displayName
                  : 'How to do ${widget.exerciseType.displayName}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            // Steps
            ...steps.asMap().entries.map((entry) {
              return _buildStepItem(entry.key + 1, entry.value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6B9FFF).withValues(alpha: 0.15),
              border: Border.all(
                color: const Color(0xFF6B9FFF).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Color(0xFF8DB8FF),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Continue Button
  // ─────────────────────────────────────────────────────────────
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 95, 151, 255),
              Color.fromARGB(255, 141, 204, 255),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: ElevatedButton(
          onPressed: _onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            elevation: 0,
          ),
          child: Text(
            _currentStep == 0 ? 'Continue' : 'Start Exercise',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
