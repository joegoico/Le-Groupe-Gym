import 'package:flutter/material.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/custom_confirm_dialog.dart';

class ExitRoutineConfirmDialog extends StatelessWidget {
  const ExitRoutineConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomConfirmDialog(
      title: 'Salir del creador',
      message: '¿Estás seguro de salir? Se perderán los datos no guardados.',
      confirmLabel: 'Salir',
      confirmColor: Colors.orange,
      headerIcon: Icons.exit_to_app,
    );
  }
}
