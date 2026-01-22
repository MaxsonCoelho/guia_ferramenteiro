import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'metal_card.dart';

class ToolCard extends StatelessWidget {
  final String name;
  final String description;
  final String summary;
  final String imagePath;
  final VoidCallback? onTap;

  const ToolCard({
    super.key,
    required this.name,
    required this.description,
    required this.summary,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MetalCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Header
          Container(
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.gunMetal,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              color: Colors.black.withOpacity(0.2),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.chrome,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.silver),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.silver,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF5C5C5C)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppTheme.steel),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summary,
                          style: const TextStyle(
                            color: AppTheme.steel,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
