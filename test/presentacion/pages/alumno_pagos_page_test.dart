import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/data/repositories/pago_repository.dart';
import 'package:le_groupe_gym/presentacion/pages/alumno_pagos_page.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../mocks/mock_pago_repository.dart';
import '../../mocks/mock_deudor_repository.dart';

class SlowReadPagoRepository extends MockPagoRepository {
  SlowReadPagoRepository({required this.readDelay});

  final Duration readDelay;

  @override
  Future<List<Pago>> getPagosPorAlumno(String idAlumno, {int? anio, int? mes}) async {
    await Future.delayed(readDelay);
    return super.getPagosPorAlumno(idAlumno, anio: anio, mes: mes);
  }

  @override
  Future<Pago?> getUltimoPago(String idAlumno) async {
    await Future.delayed(readDelay);
    return super.getUltimoPago(idAlumno);
  }
}

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

    Widget createWidgetUnderTest({PagoRepository? pagoRepository}) {
      return ProviderScope(
        overrides: [
          pagoRepositoryProvider.overrideWithValue(pagoRepository ?? mockPagoRepository),
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
      expect(find.text('CG'), findsOneWidget);
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

      expect(find.text('\$1.500'), findsOneWidget);
      expect(find.text('Efectivo'), findsWidgets);
    });

    testWidgets('debe remover el pago de la UI al primer intento aunque la recarga sea lenta', (tester) async {
      final slowRepo = SlowReadPagoRepository(readDelay: const Duration(milliseconds: 300));
      await slowRepo.insertarPago(
        Pago(
          idPago: 'p1',
          idAlumno: '1234',
          fechaDePago: DateTime.now(),
          monto: 1500,
          medioDePago: 'Efectivo',
          cantidadDias: 3,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(pagoRepository: slowRepo));
      await tester.pumpAndSettle();

      expect(find.text('\$1.500'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar').last);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('\$1.500'), findsNothing);
      expect(find.text('No hay pagos registrados este año'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
    });
  });
}
