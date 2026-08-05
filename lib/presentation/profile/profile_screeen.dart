import 'package:flutter/material.dart';
import 'widgets/profile_content_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // For demonstration, defaulting to guest state
  bool _isSignedIn = false;

  void _handleLoginSuccess() {
    setState(() {
      _isSignedIn = true;
    });
  }

  void _handleSignOut() {
    setState(() {
      _isSignedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ProfileContentView(
        isSignedIn: _isSignedIn,
        onSignOut: _handleSignOut,
        onLoginSuccess: _handleLoginSuccess,
      ),
    );
  }
}
