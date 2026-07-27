import 'package:flutter/material.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/custom_confirm_dialog.dart';

class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomConfirmDialog(
      title: 'Cerrar sesión',
      message: '¿Estás seguro que deseas cerrar sesión?',
      confirmLabel: 'Cerrar sesión',
      confirmColor: Colors.orange,
      headerIcon: Icons.logout,
    );
  }
}
