import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isDestructive;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.redAccent : theme.primaryColor;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.1) : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDestructive
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isDestructive ? Colors.redAccent : theme.colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDestructive ? Colors.redAccent : theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
