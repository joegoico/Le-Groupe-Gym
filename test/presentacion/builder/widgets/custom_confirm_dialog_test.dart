import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/custom_confirm_dialog.dart';

void main() {
  group('CustomConfirmDialog', () {
    testWidgets('Muestra el título, mensaje y botones correctamente', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomConfirmDialog(
              title: 'Título de prueba',
              message: 'Mensaje de prueba',
              confirmLabel: 'Aceptar',
              confirmColor: Colors.red,
              headerIcon: Icons.warning,
            ),
          ),
        ),
      );

      expect(find.text('Título de prueba'), findsOneWidget);
      expect(find.text('Mensaje de prueba'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Aceptar'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsWidgets);
    });

    testWidgets('Retorna false al presionar Cancelar', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => const CustomConfirmDialog(
                        title: 'Título',
                        message: 'Mensaje',
                        confirmLabel: 'Aceptar',
                        confirmColor: Colors.red,
                        headerIcon: Icons.warning,
                      ),
                    );
                  },
                  child: const Text('Mostrar Dialogo'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mostrar Dialogo'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('Retorna true al presionar Aceptar', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => const CustomConfirmDialog(
                        title: 'Título',
                        message: 'Mensaje',
                        confirmLabel: 'Aceptar',
                        confirmColor: Colors.red,
                        headerIcon: Icons.warning,
                      ),
                    );
                  },
                  child: const Text('Mostrar Dialogo'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mostrar Dialogo'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      expect(result, true);
    });
  });
}
