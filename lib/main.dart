import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'presentation/onboarding/welcome_screen.dart';
import 'app.dart';

import 'package:firebase_core/firebase_core.dart';
import 'core/network/api_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  final sharedPreferences = await SharedPreferences.getInstance();
  await ApiConstants.initialize(sharedPreferences);
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedOnboarding = ref.watch(onboardingStatusProvider);

    return MaterialApp(
      title: 'Fitness App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: hasCompletedOnboarding ? const AppScreen() : const WelcomeScreen(),
    );
  }
}
