import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

class DetalleCard extends StatelessWidget {
  final Widget child;
  final bool accentLeft;
  final Color? accentColor;

  const DetalleCard({
    super.key,
    required this.child,
    this.accentLeft = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.all(AppRadius.md),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(AppRadius.md),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (accentLeft)
                Container(width: 4, color: accentColor ?? AppColors.primary),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
