import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'metal_header.dart';

class MetalScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool showBackButton;

  const MetalScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppTheme.gunMetal,
      appBar: title != null
          ? MetalHeader(
              title: title!,
              actions: actions,
              leading: leading,
              showBackButton: showBackButton,
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.gunMetal,
          // Optional: Add a subtle gradient or texture here if desired in the future
        ),
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
