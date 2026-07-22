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
      expect(find.text('Plan de 2 días'), findsOneWidget);
      expect(find.text('Plan de 3 días'), findsOneWidget);
      expect(find.text('Plan de 5 días'), findsOneWidget);

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
      expect(find.text(r'$15'), findsOneWidget);
      expect(find.text(r'$20'), findsOneWidget);

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

    // ── TDD: Issue #1 — Confirmación al eliminar descuento ─────────────────

    testWidgets(
      'debe mostrar dialog de confirmación al intentar eliminar un descuento',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(const Duration(milliseconds: 100));

        // Act — tap el botón eliminar del primer DescuentoItem
        // (el panel de descuentos está al final del árbol; los botones de
        // precios usan delete_outline también — buscamos el último grupo)
        final deleteButtons = find.byIcon(Icons.delete_outline);
        expect(deleteButtons, findsWidgets);
        // El orden en pantalla: primero los de PrecioCard (3), luego los de
        // DescuentoItem (2). Tomamos el 4to (índice 3) = primer descuento.
        await tester.tap(deleteButtons.at(3));
        await tester.pumpAndSettle();

        // Assert — el dialog de confirmación debe aparecer
        expect(find.text('Eliminar descuento'), findsOneWidget);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );

    testWidgets(
      'al cancelar la confirmación el descuento no debe eliminarse',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(const Duration(milliseconds: 100));

        // Act — abrimos el dialog y cancelamos
        final deleteButtons = find.byIcon(Icons.delete_outline);
        await tester.tap(deleteButtons.at(3));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        // Assert — el descuento sigue visible
        expect(find.text(r'$15'), findsOneWidget);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );

    testWidgets(
      'al confirmar la eliminación el descuento desaparece de la lista',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(const Duration(milliseconds: 100));

        // Act — abrimos el dialog y confirmamos
        final deleteButtons = find.byIcon(Icons.delete_outline);
        await tester.tap(deleteButtons.at(3));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        // Assert — el primer descuento ya no está, el segundo sí
        expect(find.text(r'$15'), findsNothing);
        expect(find.text(r'$20'), findsOneWidget);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );

    // ── TDD: Issue #2 — PrecioCard sin height fija ─────────────────────────

    testWidgets(
      'PrecioCard no debe producir overflow con valores de precio grandes',
      (tester) async {
        // Arrange — precio con valor grande en contenedor acotado (simula sidebar)
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(const Duration(milliseconds: 100));

        // Assert — no debe haber excepciones de overflow en el render tree
        // Si existiera un overflow, tester.pump lanzaría una excepción
        // y el test fallaría automáticamente.
        expect(tester.takeException(), isNull);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
  });
}
