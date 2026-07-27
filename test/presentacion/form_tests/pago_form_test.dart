import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/presentacion/forms/pago_form.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import '../../mocks/mock_pago_repository.dart';
import '../../mocks/mock_precio_repository.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late MockPagoRepository mockPagoRepository;
  late MockPrecioRepository mockPrecioRepository;

  final alumnoPrueba = Alumno(
    idAlumno: 'abc',
    nombre: 'Juan',
    apellido: 'Perez',
  );

  setUp(() async {
    await initializeDateFormatting('es', null);
    mockPagoRepository = MockPagoRepository();
    mockPrecioRepository = MockPrecioRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        pagoRepositoryProvider.overrideWithValue(mockPagoRepository),
        precioRepositoryProvider.overrideWithValue(mockPrecioRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => PagoForm(alumno: alumnoPrueba),
                  );
                },
                child: const Text('Abrir'),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('debe cargar y mostrar los planes disponibles', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Registrar Pago'), findsOneWidget);
    expect(find.text('Personalizado'), findsOneWidget);
  });

  testWidgets(
    'seleccionar pago personalizado habilita monto y comentario obligatorio',
    (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Ya está seleccionado personalizado por defecto.

      // Tocar guardar sin comentarios ni monto
      await tester.ensureVisible(find.text('Confirmar Pago'));
      await tester.tap(find.text('Confirmar Pago'));
      await tester.pumpAndSettle();

      // Debería mostrar error en monto y comentario
      expect(find.text('Requerido'), findsNWidgets(2)); // Monto y Días
      expect(
        find.text('El comentario es obligatorio para pagos personalizados'),
        findsOneWidget,
      );
    },
  );

  testWidgets('guarda el pago correctamente cuando es un plan normal', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Seleccionar plan usando ChoiceChip
    await tester.ensureVisible(find.text('3 días'));
    await tester.tap(find.text('3 días'));
    await tester.pumpAndSettle();

    // Guardar
    await tester.ensureVisible(find.text('Confirmar Pago'));
    await tester.tap(find.text('Confirmar Pago'));
    await tester.pumpAndSettle();

    final ultimoPago = await mockPagoRepository.getUltimoPago('abc');
    expect(ultimoPago, isNotNull);
    expect(ultimoPago!.monto, 15000);
    expect(ultimoPago.cantidadDias, 3);
    expect(ultimoPago.medioDePago, 'Efectivo'); // Default
  });
}
