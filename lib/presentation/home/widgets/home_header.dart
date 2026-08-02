import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;

  const HomeHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Hi, $userName',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {
              
            },
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.cardColor,
              child: Icon(Icons.person, color: AppTheme.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
