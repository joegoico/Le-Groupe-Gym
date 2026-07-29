import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/presentacion/pages/alumno_pagos_page.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../mocks/mock_pago_repository.dart';
import '../../mocks/mock_deudor_repository.dart';

void main() {
  group('AlumnoPagosPage Widget Tests', () {
    late Alumno alumnoPrueba;
    late MockPagoRepository mockPagoRepository;
    late MockDeudorRepository mockDeudorRepository;

    setUp(() async {
      await initializeDateFormatting('es_ES', null);
      alumnoPrueba = Alumno(
        idAlumno: '1234',
        nombre: 'Carlos',
        apellido: 'Gómez',
      );
      mockPagoRepository = MockPagoRepository();
      mockDeudorRepository = MockDeudorRepository();
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          pagoRepositoryProvider.overrideWithValue(mockPagoRepository),
          deudorRepositoryProvider.overrideWithValue(mockDeudorRepository),
        ],
        child: MaterialApp(
          home: AlumnoPagosPage(alumno: alumnoPrueba),
        ),
      );
    }

    testWidgets('debe mostrar el nombre y avatar del alumno', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Carlos Gómez'), findsOneWidget);
      expect(find.text('CG'), findsOneWidget); // Iniciales
    });

    testWidgets('debe mostrar el botón de registrar pago', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pagos_registrar_pago_btn')), findsOneWidget);
    });

    testWidgets('debe mostrar mensaje cuando no hay pagos', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No hay pagos registrados este año'), findsOneWidget);
    });

    testWidgets('debe mostrar historial cuando hay pagos', (tester) async {
      mockPagoRepository.insertarPago(
        Pago(
          idPago: 'p1',
          idAlumno: '1234',
          fechaDePago: DateTime.now(),
          monto: 1500,
          medioDePago: 'Efectivo',
          cantidadDias: 3,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('\$1.500'), findsOneWidget); // Último pago (monto)
      expect(find.text('Efectivo'), findsWidgets);
    });
  });
}
