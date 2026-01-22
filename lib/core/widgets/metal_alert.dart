import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'metal_button.dart';

class MetalAlert extends StatelessWidget {
  final String title;
  final String description;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final IconData? icon;

  const MetalAlert({
    super.key,
    required this.title,
    required this.description,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.icon,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    String? primaryButtonText,
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      builder: (context) => MetalAlert(
        title: title,
        description: description,
        primaryButtonText: primaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonText: secondaryButtonText,
        onSecondaryPressed: onSecondaryPressed,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.brushedMetal,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF5C5C5C)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 48, color: AppTheme.silver),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.chrome,
                    fontSize: 22,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.silver,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (secondaryButtonText != null)
                  Expanded(
                    child: MetalButton.secondary(
                      label: secondaryButtonText!,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onSecondaryPressed?.call();
                      },
                    ),
                  ),
                if (secondaryButtonText != null && primaryButtonText != null)
                  const SizedBox(width: 12),
                if (primaryButtonText != null)
                  Expanded(
                    child: MetalButton(
                      label: primaryButtonText!,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onPrimaryPressed?.call();
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
