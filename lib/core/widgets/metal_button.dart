import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MetalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isFullWidth;

  const MetalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isFullWidth = false,
  });

  const MetalButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
  }) : isPrimary = false;

  @override
  Widget build(BuildContext context) {
    final style = isPrimary
        ? ElevatedButton.styleFrom(
            backgroundColor: AppTheme.silver,
            foregroundColor: AppTheme.gunMetal,
            elevation: 4,
            shadowColor: Colors.black54,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: AppTheme.silver,
            side: const BorderSide(color: AppTheme.silver, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );

    final Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );

    final Widget button = isPrimary
        ? ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: buttonContent,
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: buttonContent,
          );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
