import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? textColor;

  const SettingsListTile({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && icon != null) {
      effectiveLeading = Icon(icon!, color: iconColor ?? Theme.of(context).colorScheme.primary);
    }

    return ListTile(
      leading: effectiveLeading,
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
