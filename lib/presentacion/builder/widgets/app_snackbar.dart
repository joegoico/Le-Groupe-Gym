import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

enum SnackbarType { success, warning, error, info }

class AppSnackbar {
  /// Muestra un snackbar estilizado con variante semántica.
  /// [margin] permite desplazarlo verticalmente para acercarlo al foco.
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),

    /// Margen desde el borde inferior. Aumentar para acercarlo al centro.
    double bottomMargin = 80,
  }) {
    final config = _configFor(type);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(config.icon, size: 18, color: config.iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.subtittlesBold.copyWith(
                    color: config.textColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: config.backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          margin: EdgeInsets.only(left: 24, right: 24, bottom: bottomMargin),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(AppRadius.md),
            side: BorderSide(color: config.borderColor, width: 1),
          ),
          elevation: 6,
        ),
      );
  }

  static _SnackbarConfig _configFor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.successContent,
          textColor: AppColors.successContent,
          backgroundColor: AppColors.successContainer,
          borderColor: AppColors.successContent.withValues(alpha: 0.35),
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.warningLow,
          textColor: AppColors.warningLow,
          backgroundColor: AppColors.warningLowContent,
          borderColor: AppColors.warningLow.withValues(alpha: 0.35),
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.error,
          textColor: AppColors.error,
          backgroundColor: AppColors.errorContainer,
          borderColor: AppColors.error.withValues(alpha: 0.35),
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.onSurface,
          textColor: AppColors.onSurface,
          backgroundColor: AppColors.surfaceContainerHighest,
          borderColor: Colors.white.withValues(alpha: 0.15),
        );
    }
  }
}

class _SnackbarConfig {
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  const _SnackbarConfig({
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}
