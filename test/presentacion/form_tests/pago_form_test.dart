import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';
import 'package:le_groupe_gym/presentacion/forms/pago_form.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import '../../mocks/mock_pago_repository.dart';
import '../../mocks/mock_precio_repository.dart';

void main() {
  late MockPagoRepository mockPagoRepository;
  late MockPrecioRepository mockPrecioRepository;

  final alumnoPrueba = Alumno(
    idAlumno: 'abc',
    nombre: 'Juan',
    apellido: 'Perez',
    aplicaDescuento: false,
  );

  setUp(() {
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
    expect(find.text('Pago Personalizado'), findsOneWidget);
  });

  testWidgets(
    'seleccionar pago personalizado habilita monto y comentario obligatorio',
    (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Ya está seleccionado personalizado por defecto.

      // Tocar guardar sin comentarios ni monto
      await tester.ensureVisible(find.text('Guardar Pago'));
      await tester.tap(find.text('Guardar Pago'));
      await tester.pumpAndSettle();

      // Debería mostrar error en monto y comentario
      expect(find.text('El monto es obligatorio'), findsOneWidget);
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

    // Abrir dropdown y seleccionar plan
    await tester.tap(find.byType(DropdownButtonFormField<Precio?>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('3 días - \$15000').last);
    await tester.pumpAndSettle();

    // Guardar
    await tester.ensureVisible(find.text('Guardar Pago'));
    await tester.tap(find.text('Guardar Pago'));
    await tester.pumpAndSettle();

    final ultimoPago = await mockPagoRepository.getUltimoPago('abc');
    expect(ultimoPago, isNotNull);
    expect(ultimoPago!.monto, 15000);
    expect(ultimoPago.cantidadDias, 3);
    expect(ultimoPago.medioDePago, 'Efectivo'); // Default
  });
}
