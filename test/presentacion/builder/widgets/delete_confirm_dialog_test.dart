import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/delete_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/custom_confirm_dialog.dart';

void main() {
  testWidgets('DeleteConfirmDialog usa CustomConfirmDialog con datos correctos', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DeleteConfirmDialog(
            title: 'Eliminar Alumno',
            message: '¿Estás seguro que deseas eliminar a este alumno?',
          ),
        ),
      ),
    );

    expect(find.byType(CustomConfirmDialog), findsOneWidget);
    expect(find.text('Eliminar Alumno'), findsOneWidget);
    expect(find.text('¿Estás seguro que deseas eliminar a este alumno?'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);
  });
}
