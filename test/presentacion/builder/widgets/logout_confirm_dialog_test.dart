import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/logout_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/custom_confirm_dialog.dart';

void main() {
  testWidgets(
    'LogoutConfirmDialog usa CustomConfirmDialog con datos correctos',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LogoutConfirmDialog())),
      );

      expect(find.byType(CustomConfirmDialog), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsNWidgets(2));
      expect(
        find.text('¿Estás seguro que deseas cerrar sesión?'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.logout), findsWidgets);
    },
  );
}
