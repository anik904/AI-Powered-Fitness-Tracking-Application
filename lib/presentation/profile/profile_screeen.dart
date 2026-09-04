import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/provider/auth_provider.dart';
import '../onboarding/welcome_screen.dart';
import 'widgets/profile_content_view.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ProfileContentView(
        isSignedIn: authState.isSignedIn,
        onSignOut: () async {
          await ref.read(authProvider.notifier).signOut();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (route) => false,
            );
          }
        },
        onLoginSuccess: () {

        },
      ),
    );
  }
}
