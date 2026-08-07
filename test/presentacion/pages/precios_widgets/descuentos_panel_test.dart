import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';
import 'package:le_groupe_gym/presentacion/pages/precios_widgets/descuentos_panel.dart';

void main() {
  group('DescuentosPanel Widget Tests', () {
    // Datos de prueba reutilizables
    final descuentoA = Descuento(id: 'abc-123', valor: 15);
    final descuentoB = Descuento(id: 'def-456', valor: 20);

    Widget createWidgetUnderTest({
      List<Descuento>? descuentos,
      VoidCallback? onAgregarDescuento,
      Function(Descuento)? onEliminarDescuento,
      Function(Descuento)? onEditarDescuento,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DescuentosPanel(
            descuentos: descuentos ?? [],
            onAgregarDescuento: onAgregarDescuento ?? () {},
            onEliminarDescuento: onEliminarDescuento ?? (_) {},
            onEditarDescuento: onEditarDescuento ?? (_) {},
          ),
        ),
      );
    }

    // ── Rendering base ──────────────────────────────────────────────────────

    testWidgets('debe mostrar el título del panel', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Descuentos'), findsOneWidget);
    });

    testWidgets(
      'debe mostrar mensaje de estado vacío cuando no hay descuentos',
      (tester) async {
        // Arrange + Act
        await tester.pumpWidget(createWidgetUnderTest(descuentos: []));

        // Assert
        expect(find.text('Sin descuentos activos'), findsOneWidget);
      },
    );

    testWidgets('debe mostrar el botón de agregar (+)', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    // ── Rendering de items ──────────────────────────────────────────────────

    testWidgets('debe mostrar cada descuento de la lista', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(
        createWidgetUnderTest(descuentos: [descuentoA, descuentoB]),
      );

      // Assert — ambos valores deben estar visibles con formato $X
      expect(find.text(r'$15'), findsOneWidget);
      expect(find.text(r'$20'), findsOneWidget);
    });

    testWidgets('no debe mostrar items cuando la lista está vacía', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest(descuentos: []));

      // Assert — no hay DescuentoItem renderizados
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      // El mensaje de estado vacío debe estar presente
      expect(find.text('Sin descuentos activos'), findsOneWidget);
    });

    testWidgets(
      'debe renderizar tantos DescuentoItem como descuentos haya en la lista',
      (tester) async {
        // Arrange + Act
        await tester.pumpWidget(
          createWidgetUnderTest(descuentos: [descuentoA, descuentoB]),
        );

        // Assert — 2 descuentos → 2 botones editar y 2 botones eliminar
        expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));
        expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
      },
    );

    // ── Callbacks ───────────────────────────────────────────────────────────

    testWidgets('debe llamar onAgregarDescuento al presionar el botón +', (
      tester,
    ) async {
      // Arrange
      bool agregado = false;
      await tester.pumpWidget(
        createWidgetUnderTest(onAgregarDescuento: () => agregado = true),
      );

      // Act
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Assert
      expect(agregado, isTrue);
    });

    testWidgets('debe llamar onEliminarDescuento con el descuento correcto', (
      tester,
    ) async {
      // Arrange
      Descuento? eliminado;
      await tester.pumpWidget(
        createWidgetUnderTest(
          descuentos: [descuentoA, descuentoB],
          onEliminarDescuento: (d) => eliminado = d,
        ),
      );

      // Act — tap en el primer botón eliminar (descuentoA)
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();

      // Assert
      expect(eliminado, isNotNull);
      expect(eliminado!.id, descuentoA.id);
      expect(eliminado!.valor, descuentoA.valor);
    });

    testWidgets('debe llamar onEditarDescuento con el descuento correcto', (
      tester,
    ) async {
      // Arrange
      Descuento? editado;
      await tester.pumpWidget(
        createWidgetUnderTest(
          descuentos: [descuentoA, descuentoB],
          onEditarDescuento: (d) => editado = d,
        ),
      );

      // Act — tap en el primer botón editar (descuentoA)
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pump();

      // Assert
      expect(editado, isNotNull);
      expect(editado!.id, descuentoA.id);
      expect(editado!.valor, descuentoA.valor);
    });

    testWidgets(
      'debe llamar onEliminarDescuento del segundo item al presionar el segundo botón eliminar',
      (tester) async {
        // Arrange
        Descuento? eliminado;
        await tester.pumpWidget(
          createWidgetUnderTest(
            descuentos: [descuentoA, descuentoB],
            onEliminarDescuento: (d) => eliminado = d,
          ),
        );

        // Act — tap en el SEGUNDO botón eliminar (descuentoB)
        await tester.tap(find.byIcon(Icons.delete_outline).last);
        await tester.pump();

        // Assert
        expect(eliminado!.id, descuentoB.id);
        expect(eliminado!.valor, descuentoB.valor);
      },
    );
  });
}
