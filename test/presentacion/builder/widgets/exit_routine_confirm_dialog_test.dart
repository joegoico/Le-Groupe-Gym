import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/exit_routine_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/custom_confirm_dialog.dart';

void main() {
  testWidgets(
    'ExitRoutineConfirmDialog usa CustomConfirmDialog con datos correctos',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ExitRoutineConfirmDialog())),
      );

      expect(find.byType(CustomConfirmDialog), findsOneWidget);
      expect(find.text('Salir del creador'), findsOneWidget);
      expect(
        find.text(
          '¿Estás seguro de salir? Se perderán los datos no guardados.',
        ),
        findsOneWidget,
      );
      expect(find.text('Salir'), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app), findsWidgets);
    },
  );
}
