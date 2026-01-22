import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'metal_button.dart';

class MetalBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  const MetalBottomSheet({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    IconData? icon,
    String? primaryButtonText,
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MetalBottomSheet(
        title: title,
        description: description,
        icon: icon,
        primaryButtonText: primaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonText: secondaryButtonText,
        onSecondaryPressed: onSecondaryPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Highly responsive height calculation
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height * 0.5; // Half screen

    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: AppTheme.brushedMetal,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: Color(0xFF5C5C5C), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.silver.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          if (icon != null) ...[
            Icon(icon, size: 48, color: AppTheme.silver),
            const SizedBox(height: 16),
          ],
          
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.chrome,
                  fontSize: 24,
                ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.silver,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Column(
            children: [
              if (primaryButtonText != null)
                MetalButton(
                  label: primaryButtonText!,
                  isFullWidth: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPrimaryPressed?.call();
                  },
                ),
              
              if (primaryButtonText != null && secondaryButtonText != null)
                const SizedBox(height: 12),
                
              if (secondaryButtonText != null)
                MetalButton.secondary(
                  label: secondaryButtonText!,
                  isFullWidth: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSecondaryPressed?.call();
                  },
                ),
            ],
          ),
          SizedBox(height: mediaQuery.padding.bottom), // Safe area
        ],
      ),
    );
  }
}
