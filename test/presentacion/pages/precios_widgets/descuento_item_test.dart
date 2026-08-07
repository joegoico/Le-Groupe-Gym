import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';
import 'package:le_groupe_gym/presentacion/pages/precios_widgets/descuento_item.dart';

void main() {
  group('DescuentoItem Widget Tests', () {
    Widget createWidgetUnderTest({
      required Descuento descuento,
      VoidCallback? onEliminar,
      VoidCallback? onEditar,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DescuentoItem(
            descuento: descuento,
            onEliminar: onEliminar ?? () {},
            onEditar: onEditar ?? () {},
          ),
        ),
      );
    }

    // ── Rendering ───────────────────────────────────────────────────────────

    testWidgets(r'debe mostrar el valor del descuento con formato $X', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(
        createWidgetUnderTest(descuento: Descuento(id: 'abc-123', valor: 15)),
      );

      // Assert
      expect(find.text(r'$15'), findsOneWidget);
    });

    testWidgets('debe mostrar el ícono de editar', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(
        createWidgetUnderTest(descuento: Descuento(id: 'abc-123', valor: 15)),
      );

      // Assert
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('debe mostrar el ícono de eliminar', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(
        createWidgetUnderTest(descuento: Descuento(id: 'abc-123', valor: 15)),
      );

      // Assert
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('debe mostrar correctamente distintos valores de descuento', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(
        createWidgetUnderTest(descuento: Descuento(id: 'xyz-999', valor: 2000)),
      );

      // Assert
      expect(find.text(r'$2000'), findsOneWidget);
      expect(find.text(r'$15'), findsNothing);
    });

    // ── Callbacks ───────────────────────────────────────────────────────────

    testWidgets('debe llamar onEditar al presionar el ícono de editar', (
      tester,
    ) async {
      // Arrange
      bool editado = false;
      await tester.pumpWidget(
        createWidgetUnderTest(
          descuento: Descuento(id: 'abc-123', valor: 15),
          onEditar: () => editado = true,
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pump();

      // Assert
      expect(editado, isTrue);
    });

    testWidgets('debe llamar onEliminar al presionar el ícono de eliminar', (
      tester,
    ) async {
      // Arrange
      bool eliminado = false;
      await tester.pumpWidget(
        createWidgetUnderTest(
          descuento: Descuento(id: 'abc-123', valor: 15),
          onEliminar: () => eliminado = true,
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      // Assert
      expect(eliminado, isTrue);
    });

    testWidgets('onEditar y onEliminar son independientes entre sí', (
      tester,
    ) async {
      // Arrange
      bool editado = false;
      bool eliminado = false;
      await tester.pumpWidget(
        createWidgetUnderTest(
          descuento: Descuento(id: 'abc-123', valor: 15),
          onEditar: () => editado = true,
          onEliminar: () => eliminado = true,
        ),
      );

      // Act — solo tocamos editar
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pump();

      // Assert — onEliminar no fue invocado
      expect(editado, isTrue);
      expect(eliminado, isFalse);
    });
  });
}
