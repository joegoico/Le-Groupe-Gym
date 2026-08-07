import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class GlobalMessenger {
  static void showSuccessSnackbar(String message) {
    _showSnackbar(
      message,
      AppColors.successContainer,
      AppColors.successContent,
    );
  }

  static void showErrorSnackbar(String message) {
    _showSnackbar(message, AppColors.errorContainer, AppColors.error);
  }

  static void _showSnackbar(
    String message,
    Color backgroundColor,
    Color textColor,
  ) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.subtittlesBold.copyWith(color: textColor),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.md),
        ),
      ),
    );
  }
}
