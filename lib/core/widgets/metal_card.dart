import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MetalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const MetalCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.brushedMetal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF5C5C5C),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(2, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.white10,
            offset: Offset(-1, -1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
