import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/provider/auth_provider.dart';
import '../../core/provider/exercise_goal_provider.dart';
import '../../core/providers/shared_preferences_provider.dart';
import '../../repository/model/exercise_type.dart';
import '../../app.dart';
import '../../widgets/exercise_icon_widget.dart';
import '../profile/auth/login_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pushupGoalController = TextEditingController(text: '20');
  final TextEditingController _squatGoalController = TextEditingController(text: '20');
  final TextEditingController _jumpingJackGoalController = TextEditingController(text: '50');

  int _parseGoal(TextEditingController controller, int fallback) {
    final parsed = int.tryParse(controller.text.trim());
    if (parsed == null || parsed <= 0) {
      return fallback;
    }
    return parsed;
  }

  void _nextPage() {
    // Page index 1 is name input
    if (_currentPage == 1 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name to continue.')),
      );
      return;
    }

    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _skipToApp() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('has_completed_onboarding', true);
    await prefs.setBool('is_guest_mode', true);
    await prefs.remove('user_email');
    await prefs.remove('onboarding_name');
    await prefs.setString('user_name', 'Guest User');

    // Ensure any lingering Firebase session is signed out
    await ref.read(authProvider.notifier).signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _openSignIn() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    if (result == true && mounted) {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('has_completed_onboarding', true);
      await prefs.setBool('is_guest_mode', false);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _finishOnboarding() async {
    final pushupGoal = _parseGoal(_pushupGoalController, 20);
    final squatGoal = _parseGoal(_squatGoalController, 20);
    final jumpingJackGoal = _parseGoal(_jumpingJackGoalController, 50);

    final goalNotifier = ref.read(exerciseGoalProvider.notifier);
    goalNotifier.updateGoalByType(ExerciseType.pushup, target: pushupGoal);
    goalNotifier.updateGoalByType(ExerciseType.squat, target: squatGoal);
    goalNotifier.updateGoalByType(ExerciseType.jumpingJack, target: jumpingJackGoal);

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('has_completed_onboarding', true);
    await prefs.setBool('is_guest_mode', true);
    await prefs.remove('user_email');

    // Sign out of any previous Firebase session so guest mode is clean
    await ref.read(authProvider.notifier).signOut();

    final trimmedName = _nameController.text.trim();
    final finalName = trimmedName.isNotEmpty ? trimmedName : 'Guest User';
    await prefs.setString('user_name', finalName);
    await prefs.setString('onboarding_name', finalName);
    await prefs.setString(
      'user_goal',
      'Push-ups: $pushupGoal, Squats: $squatGoal, Jumping Jacks: $jumpingJackGoal reps/day',
    );
    await prefs.setInt('pushup_goal', pushupGoal);
    await prefs.setInt('squat_goal', squatGoal);
    await prefs.setInt('jumping_jack_goal', jumpingJackGoal);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _pushupGoalController.dispose();
    _squatGoalController.dispose();
    _jumpingJackGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppTheme.textPrimary,
          onPressed: _previousPage,
        ),
        actions: [
          TextButton(
            onPressed: _openSignIn,
            child: Text(
              'Sign In',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: _skipToApp,
            child: Text(
              'Skip',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildAppInfoScreen(),
                  _buildNameInputScreen(),
                  _buildGoalInputScreen(),
                  _buildFinalScreen(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 100, color: AppTheme.accentColor),
          const SizedBox(height: 32),
          Text(
            'Track & Improve',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Get real-time feedback on your posture, track your progress, and reach your fitness goals with advanced AI pose detection.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNameInputScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'What should we call you?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: AppTheme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
              ),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
            textAlign: TextAlign.center,
            onSubmitted: (_) => _nextPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalInputScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Set your daily rep goals',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Choose daily targets for each exercise. You can update them later.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildGoalInputField(
            exerciseType: ExerciseType.pushup,
            title: 'Push-ups',
            controller: _pushupGoalController,
            hintText: '20',
          ),
          const SizedBox(height: 12),
          _buildGoalInputField(
            exerciseType: ExerciseType.squat,
            title: 'Squats',
            controller: _squatGoalController,
            hintText: '20',
          ),
          const SizedBox(height: 12),
          _buildGoalInputField(
            exerciseType: ExerciseType.jumpingJack,
            title: 'Jumping Jacks',
            controller: _jumpingJackGoalController,
            hintText: '50',
          ),
        ],
      ),
    );
  }

  Widget _buildGoalInputField({
    required ExerciseType exerciseType,
    required String title,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExerciseIconWidget(
            exerciseType: exerciseType,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: hintText,
              suffixText: 'reps',
              filled: true,
              fillColor: AppTheme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
              ),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFinalScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
          const SizedBox(height: 32),
          Text(
            'All Set!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'You are now ready to begin your fitness journey.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Step indicators
          Row(
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? AppTheme.accentColor
                      : AppTheme.textSecondary.withValues(alpha: 0.3),
                ),
              );
            }),
          ),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              _currentPage == 3 ? 'Get Started' : 'Next',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
