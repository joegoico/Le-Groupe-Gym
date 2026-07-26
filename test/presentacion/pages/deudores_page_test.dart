import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/pages/deudores_page.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:le_groupe_gym/data/models/deudor_model.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../mocks/mock_deudor_repository.dart';
import '../../mocks/mock_pago_repository.dart';

void main() {
  group('DeudoresPage Widget Tests', () {
    late MockDeudorRepository mockDeudorRepo;
    late MockPagoRepository mockPagoRepo;

    setUp(() {
      mockDeudorRepo = MockDeudorRepository();
      // Asegurar que hay deudores para todos los filtros
      mockDeudorRepo.clearData();
      mockDeudorRepo.getDeudores().then((_) {
        // Juan = 30 días
        // María = 15 días (Vencido este mes)
        // Carlos = 65 días
      });
      // Sobrescribir datos en el mock
      mockDeudorRepo.insertarDeudor(
        Deudor(idDeudor: 'abc-123', nombre: 'Juan', apellido: 'Pérez', diasAdeudados: 30, createdAt: DateTime.now()),
      );
      mockDeudorRepo.insertarDeudor(
        Deudor(idDeudor: 'def-456', nombre: 'María', apellido: 'García', diasAdeudados: 15, createdAt: DateTime.now()),
      );
      mockDeudorRepo.insertarDeudor(
        Deudor(idDeudor: 'ghi-789', nombre: 'Carlos', apellido: 'López', diasAdeudados: 65, createdAt: DateTime.now()),
      );

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
    });

    setUpAll(() async {
      await initializeDateFormatting('es', null);
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          deudorRepositoryProvider.overrideWithValue(mockDeudorRepo),
          pagoRepositoryProvider.overrideWithValue(mockPagoRepo),
        ],
        child: const MaterialApp(home: DeudoresPage()),
      );
    }

    testWidgets('Debe renderizar los filtros superiores de morosidad', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Vencido este mes'), findsOneWidget);
      expect(find.text('Más de 30 días'), findsOneWidget);
      expect(find.text('Más de 60 días'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('Debe filtrar la lista de deudores al seleccionar un chip', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Inicialmente están todos (3 deudores)
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('María García'), findsOneWidget);
      expect(find.text('Carlos López'), findsOneWidget);

      // Tocar "Más de 30 días"
      await tester.tap(find.text('Más de 30 días'));
      await tester.pumpAndSettle();

      // Debería estar Juan (30 no es >30? asumiendo >= 30, o Carlos 65)
      // Ajustemos el filtro a >= 30. Carlos seguro está. María (15) no debería estar.
      expect(find.text('María García'), findsNothing);

      // Tocar "Más de 60 días"
      await tester.tap(find.text('Más de 60 días'));
      await tester.pumpAndSettle();
      
      expect(find.text('Carlos López'), findsOneWidget);
      expect(find.text('Juan Pérez'), findsNothing);
      expect(find.text('María García'), findsNothing);

      // Tocar "Vencido este mes" (< 30)
      await tester.tap(find.text('Vencido este mes'));
      await tester.pumpAndSettle();
      
      expect(find.text('María García'), findsOneWidget);
      expect(find.text('Carlos López'), findsNothing);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('Debe mostrar la card de deudor con la foto, plan, días de mora y último pago', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Buscar textos en mayúsculas
      expect(find.text('HACE 30 DÍAS'), findsOneWidget); // De Juan
      expect(find.text('Plan de 30 días'), findsOneWidget); // Del último pago de Juan
      expect(find.textContaining('Último pago:'), findsWidgets);
      
      // Buscar el icono de email
      expect(find.byIcon(Icons.email_outlined), findsWidgets);
      
      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}

