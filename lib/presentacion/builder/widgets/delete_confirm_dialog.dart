import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/custom_confirm_dialog.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final String title;
  final String message;

  const DeleteConfirmDialog({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return CustomConfirmDialog(
      title: title,
      message: message,
      confirmLabel: 'Eliminar',
      confirmColor: AppColors.error,
      headerIcon: Icons.delete_outline,
    );
  }
}
