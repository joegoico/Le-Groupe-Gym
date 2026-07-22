import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';
import 'package:le_groupe_gym/presentacion/forms/descuento_form.dart';

void main() {
  group('DescuentoForm Widget Tests', () {
    Widget createWidgetUnderTest({
      Descuento? descuento,
      Function(Descuento)? onGuardar,
      VoidCallback? onCancelar,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DescuentoForm(
            descuento: descuento,
            onGuardar: onGuardar ?? (_) {},
            onCancelar: onCancelar ?? () {},
          ),
        ),
      );
    }

    testWidgets('debe mostrar el campo de valor', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byKey(const Key('descuento_valor_field')), findsOneWidget);
    });

    testWidgets('debe mostrar botones Cancelar y Guardar', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets(
      'el botón Guardar debe estar deshabilitado si el campo está vacío',
      (tester) async {
        // Arrange + Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Assert
        final boton = tester.widget<ElevatedButton>(
          find.ancestor(
            of: find.text('Guardar'),
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(boton.onPressed, isNull);
      },
    );

    testWidgets('el botón Guardar debe habilitarse al ingresar un valor', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(
        find.byKey(const Key('descuento_valor_field')),
        '15',
      );
      await tester.pump();

      // Assert
      final boton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Guardar'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(boton.onPressed, isNotNull);
    });

    testWidgets('debe precargar el valor si se edita un descuento existente', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(
        createWidgetUnderTest(descuento: Descuento(id: 'abc-123', valor: 15)),
      );

      // Assert
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('debe llamar onCancelar al presionar Cancelar', (tester) async {
      // Arrange
      bool cancelado = false;
      await tester.pumpWidget(
        createWidgetUnderTest(onCancelar: () => cancelado = true),
      );

      // Act
      await tester.tap(find.text('Cancelar'));
      await tester.pump();

      // Assert
      expect(cancelado, isTrue);
    });

    testWidgets('debe llamar onGuardar con el descuento correcto', (
      tester,
    ) async {
      // Arrange
      Descuento? guardado;
      await tester.pumpWidget(
        createWidgetUnderTest(onGuardar: (d) => guardado = d),
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('descuento_valor_field')),
        '20',
      );
      await tester.pump();
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // Assert
      expect(guardado, isNotNull);
      expect(guardado!.valor, 20);
    });
    testWidgets('debe mostrar error si el valor es 0', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(
        find.byKey(const Key('descuento_valor_field')),
        '0',
      );
      await tester.pump();

      // Assert
      expect(find.text('El valor debe ser mayor a 0'), findsOneWidget);
      final boton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Guardar'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(boton.onPressed, isNull);
    });

    testWidgets('debe enviar el formulario al presionar Enter', (tester) async {
      // Arrange
      Descuento? guardado;
      await tester.pumpWidget(
        createWidgetUnderTest(onGuardar: (d) => guardado = d),
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('descuento_valor_field')),
        '15',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Assert
      expect(guardado, isNotNull);
      expect(guardado!.valor, 15);
    });
  });
}
