import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      title: Text(titulo, style: AppTextStyles.headlineLg),
      content: Text(mensaje, style: AppTextStyles.titleMd),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Cancelar', style: AppTextStyles.titleMd),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Eliminar',
            style: AppTextStyles.titleMd.copyWith(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
