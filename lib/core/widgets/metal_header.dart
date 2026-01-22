import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MetalHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;

  const MetalHeader({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.gunMetal,
      elevation: 4,
      shadowColor: Colors.black54,
      centerTitle: centerTitle,
      automaticallyImplyLeading: showBackButton,
      leading: leading ?? (showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.silver),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null),
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.chrome,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: Colors.black54,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFF5C5C5C),
          height: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
