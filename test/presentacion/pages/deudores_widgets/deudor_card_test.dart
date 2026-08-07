import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/deudor_model.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/presentacion/pages/deudores_widgets/deudor_card.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../mocks/mock_pago_repository.dart';

void main() {
  group('DeudorCard Widget Tests', () {
    late MockPagoRepository mockPagoRepo;
    late Deudor deudorMock;

    setUp(() {
      mockPagoRepo = MockPagoRepository();
      mockPagoRepo.insertarPago(
        Pago(
          idPago: 'p1',
          idAlumno: 'abc-123',
          monto: 1000,
          cantidadDias: 30,
          fechaDePago: DateTime.now().subtract(const Duration(days: 60)),
          medioDePago: 'Efectivo',
        ),
      );

      deudorMock = Deudor(
        idDeudor: 'abc-123',
        nombre: 'Juan',
        apellido: 'Pérez',
        diasAdeudados: 45,
        createdAt: DateTime.now(),
      );
    });

    setUpAll(() async {
      await initializeDateFormatting('es', null);
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [pagoRepositoryProvider.overrideWithValue(mockPagoRepo)],
        child: MaterialApp(
          home: Scaffold(
            body: DeudorCard(deudor: deudorMock, onRegistrarPago: () {}),
          ),
        ),
      );
    }

    testWidgets('Debe mostrar la foto, plan, días de mora y último pago', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester
          .pumpAndSettle(); // para esperar al FutureProvider/FutureBuilder

      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('HACE 45 DÍAS'), findsOneWidget); // Badge
      expect(
        find.text('Plan de 30 días'),
        findsOneWidget,
      ); // Plan deducido de Pago
      expect(find.textContaining('Último pago:'), findsOneWidget);
      expect(
        find.byIcon(Icons.email_outlined),
        findsOneWidget,
      ); // Footer email icon
    });

    testWidgets(
      'Debe disparar el callback de Registrar Pago y Enviar Mensaje',
      (tester) async {
        bool pagoRegistrado = false;
        bool mensajeEnviado = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [pagoRepositoryProvider.overrideWithValue(mockPagoRepo)],
            child: MaterialApp(
              home: Scaffold(
                body: DeudorCard(
                  deudor: deudorMock,
                  onRegistrarPago: () {
                    pagoRegistrado = true;
                  },
                  onEnviarMensaje: () {
                    mensajeEnviado = true;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Registrar Pago'));

        // Tap on Email icon
        await tester.tap(find.byIcon(Icons.email_outlined));

        await tester.pumpAndSettle();

        expect(pagoRegistrado, true);
        expect(mensajeEnviado, true);
      },
    );

    testWidgets('No expone acciones para eliminar o editar una deuda', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });
  });
}
