import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/resumen_mensual_model.dart';
import 'package:le_groupe_gym/presentacion/pages/ingresos_widgets/resumen_mensual_card.dart';

void main() {
  group('ResumenMensualCard Widget Tests', () {
    final mockResumen = ResumenMensual(
      mes: 6,
      anio: 2026,
      totalEfectivo: 15000,
      totalTransferencia: 18000,
      total: 33000,
    );

    Widget createWidgetUnderTest({VoidCallback? onVerDetalle}) {
      return MaterialApp(
        home: Scaffold(
          body: ResumenMensualCard(
            resumen: mockResumen,
            onVerDetalle: onVerDetalle ?? () {},
          ),
        ),
      );
    }

    testWidgets('debe mostrar el título del mes', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Junio 2026'), findsOneWidget);
    });

    testWidgets('debe mostrar el total de ingresos', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.textContaining('33.000'), findsOneWidget);
    });

    testWidgets('debe mostrar el desglose de efectivo', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Efectivo'), findsOneWidget);
      expect(find.textContaining('15.000'), findsOneWidget);
    });

    testWidgets('debe mostrar el desglose de transferencia', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Transferencia'), findsOneWidget);
      expect(find.textContaining('18.000'), findsOneWidget);
    });

    testWidgets('debe mostrar botón Ver Detalles', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Ver Detalles del Mes →'), findsOneWidget);
    });

    testWidgets('debe llamar onVerDetalle al presionar el botón', (
      tester,
    ) async {
      // Arrange
      bool pressed = false;
      await tester.pumpWidget(
        createWidgetUnderTest(onVerDetalle: () => pressed = true),
      );

      // Act
      await tester.tap(find.text('Ver Detalles del Mes →'));
      await tester.pump();

      // Assert
      expect(pressed, isTrue);
    });
  });
}
