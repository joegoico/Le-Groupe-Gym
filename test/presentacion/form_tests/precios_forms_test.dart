import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/forms/precio_form.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';
import '../../mocks/mock_precio_repository.dart';

void main() {
  group('PrecioForm Tests', () {
    Widget createWidgetUnderTest({
      VoidCallback? onCancelar,
      ValueChanged<Precio>? onGuardar,
      required MockPrecioRepository precioRepository,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: PrecioForm(
            onCancelar: onCancelar ?? () {},
            onGuardar: onGuardar ?? (_) {},
            precioRepository: precioRepository,
          ),
        ),
      );
    }

    testWidgets('debe mostrar el formulario correctamente', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(precioRepository: MockPrecioRepository()),
      );

      expect(find.text('Nuevo Precio'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('debe validar que todos los campos sean requeridos', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(precioRepository: MockPrecioRepository()),
      );

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();

      expect(find.text('El precio es requerido'), findsOneWidget);
      expect(find.text('La cantidad de días es requerida'), findsOneWidget);
    });

    testWidgets('debe validar que el precio sea mayor a 0', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(precioRepository: MockPrecioRepository()),
      );

      await tester.enterText(find.byType(TextFormField).at(0), '0');
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();

      expect(find.text('El precio debe ser mayor a 0'), findsOneWidget);
    });

    testWidgets('debe validar que el precio sea numérico', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(precioRepository: MockPrecioRepository()),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'precio');
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();

      expect(find.text('El precio debe ser un número válido'), findsOneWidget);
    });

    testWidgets('debe llamar a onGuardar al presionar el botón de guardar', (
      tester,
    ) async {
      bool guardado = false;
      Precio precioGuardado;

      await tester.pumpWidget(
        createWidgetUnderTest(
          precioRepository: MockPrecioRepository(),
          onGuardar: (precio) {
            guardado = true;
            precioGuardado = precio;
          },
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), '50000');
      await tester.enterText(find.byType(TextFormField).at(1), '2');

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();

      expect(guardado, isTrue);
    });

    testWidgets('debe llamar a onCancelar al presionar el botón de cancelar', (
      tester,
    ) async {
      bool cancelado = false;

      await tester.pumpWidget(
        createWidgetUnderTest(
          precioRepository: MockPrecioRepository(),
          onCancelar: () => cancelado = true,
        ),
      );

      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();

      expect(cancelado, isTrue);
    });
  });
}
