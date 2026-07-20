import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/pages/precios_page.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import '../../mocks/mock_precio_repository.dart';
import '../../mocks/mock_descuento_repository.dart';

void main() {
  group('PreciosPage Widget Tests', () {
    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          precioRepositoryProvider.overrideWithValue(MockPrecioRepository()),
          descuentoRepositoryProvider.overrideWithValue(
            MockDescuentoRepository(),
          ),
        ],
        child: const MaterialApp(home: PreciosPage()),
      );
    }

    testWidgets('debe mostrar indicador de carga inicial', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar los precios tras cargar', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(
        Duration(milliseconds: 100),
      ); // Simula la espera de la carga

      // Assert — mock tiene 3 precios
      expect(find.text('2 días'), findsOneWidget);
      expect(find.text('3 días'), findsOneWidget);
      expect(find.text('5 días'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar los descuentos tras cargar', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(
        Duration(milliseconds: 100),
      ); // Simula la espera de la carga

      // Assert — mock tiene 2 descuentos
      expect(find.text('-15%'), findsOneWidget);
      expect(find.text('-20%'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar botón nuevo plan', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(
        Duration(milliseconds: 100),
      ); // Simula la espera de la carga

      // Assert
      expect(find.text('Nuevo Plan'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
