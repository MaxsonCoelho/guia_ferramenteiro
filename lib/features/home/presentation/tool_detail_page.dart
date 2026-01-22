import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';

class ToolDetailPage extends StatelessWidget {
  final String toolName;
  final String description;
  final String imagePath;
  final VoidCallback? onMeasurementTap;

  const ToolDetailPage({
    super.key,
    required this.toolName,
    required this.description,
    required this.imagePath,
    this.onMeasurementTap,
  });

  @override
  Widget build(BuildContext context) {
    return MetalScaffold(
      title: toolName,
      showBackButton: true,
      body: Column(
        children: [
          // Top: Image
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.brushedMetal),
              ),
              padding: const EdgeInsets.all(24),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Bottom: Content
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DESCRIÇÃO',
                            style: TextStyle(
                              color: AppTheme.silver.withOpacity(0.7),
                              fontSize: 14,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              color: AppTheme.chrome,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (onMeasurementTap != null) ...[
                    const SizedBox(height: 16),
                    MetalButton(
                      label: 'Ir para Medição',
                      icon: Icons.straighten,
                      isPrimary: true,
                      isFullWidth: true,
                      onPressed: onMeasurementTap!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
