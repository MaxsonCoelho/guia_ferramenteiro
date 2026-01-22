import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MetalCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? label;

  const MetalCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.silver,
          checkColor: AppTheme.gunMetal,
          side: const BorderSide(color: AppTheme.silver, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 8),
          Text(
            label!,
            style: const TextStyle(
              color: AppTheme.silver,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
