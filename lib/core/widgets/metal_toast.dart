import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MetalToast {
  static void show(BuildContext context, {
    required String message,
    IconData? icon,
    Color? accentColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.brushedMetal,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: accentColor ?? AppTheme.silver,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: accentColor ?? AppTheme.silver),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.chrome,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, icon: Icons.check_circle, accentColor: Colors.green);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, icon: Icons.error, accentColor: const Color(0xFFCF6679));
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, icon: Icons.info, accentColor: AppTheme.steel);
  }
}
