import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final IconData headerIcon;

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Eliminar',
    this.confirmColor = AppColors.error,
    this.headerIcon = Icons.delete_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.all(AppRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── HEADER ────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: const BorderRadius.vertical(top: AppRadius.md),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.onSurface.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Ícono de acción destructiva (o la que se configure)
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: confirmColor.withValues(alpha: 0.20),
                        borderRadius: const BorderRadius.all(AppRadius.sm),
                      ),
                      child: Icon(headerIcon, color: confirmColor, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.subtittlesBold.copyWith(
                          fontSize: 15,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.onSurfaceVariant,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // ── BODY ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      message,
                      style: AppTextStyles.subtittles.copyWith(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.onSurfaceVariant,
                                side: const BorderSide(
                                  color: AppColors.outlineVariant,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(AppRadius.md),
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style: AppTextStyles.subtittlesBold.copyWith(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(true),
                              icon: Icon(
                                headerIcon,
                                size: 15,
                                color: confirmColor,
                              ),
                              label: Text(
                                confirmLabel,
                                style: AppTextStyles.subtittlesBold.copyWith(
                                  fontSize: 13,
                                  color: confirmColor,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: confirmColor.withValues(
                                  alpha: 0.25,
                                ),
                                foregroundColor: confirmColor,
                                elevation: 0,
                                side: BorderSide(
                                  color: confirmColor.withValues(alpha: 0.30),
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(AppRadius.md),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
