import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/custom_confirm_dialog.dart';

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
    builder: (ctx) => CustomConfirmDialog(
      title: titulo,
      message: mensaje,
      confirmLabel: confirmLabel,
      confirmColor: confirmColor,
      headerIcon: headerIcon,
    ),
  );
  return result ?? false;
}
