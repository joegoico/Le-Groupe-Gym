import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String confirmLabel = 'Eliminar',
  Color confirmColor = AppColors.error,
  IconData headerIcon = Icons.delete_outline,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (ctx) => Dialog(
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
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
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
                  borderRadius:
                      const BorderRadius.vertical(top: AppRadius.md),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.onSurface.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Ícono de acción destructiva
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer
                            .withValues(alpha: 0.20),
                        borderRadius:
                            const BorderRadius.all(AppRadius.sm),
                      ),
                      child: Icon(
                        headerIcon,
                        color: AppColors.error,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        titulo,
                        style: AppTextStyles.subtittlesBold.copyWith(
                          fontSize: 15,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.of(ctx).pop(false),
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
                      mensaje,
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
                              onPressed: () =>
                                  Navigator.of(ctx).pop(false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    AppColors.onSurfaceVariant,
                                side: const BorderSide(
                                  color: AppColors.outlineVariant,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(AppRadius.md),
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style: AppTextStyles.subtittlesBold
                                    .copyWith(
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
                              onPressed: () =>
                                  Navigator.of(ctx).pop(true),
                              icon: Icon(
                                headerIcon,
                                size: 15,
                                color: confirmColor,
                              ),
                              label: Text(
                                confirmLabel,
                                style: AppTextStyles.subtittlesBold
                                    .copyWith(
                                  fontSize: 13,
                                  color: confirmColor,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.errorContainer
                                        .withValues(alpha: 0.25),
                                foregroundColor: confirmColor,
                                elevation: 0,
                                side: BorderSide(
                                  color: confirmColor.withValues(
                                    alpha: 0.30,
                                  ),
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(AppRadius.md),
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
    ),
  );
  return result ?? false;
}
