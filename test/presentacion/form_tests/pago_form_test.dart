import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/data/repositories/pago_repository.dart';
import 'package:le_groupe_gym/presentacion/forms/pago_form.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import '../../mocks/mock_pago_repository.dart';
import '../../mocks/mock_precio_repository.dart';
import '../../mocks/mock_descuento_repository.dart';
import 'package:intl/date_symbol_data_local.dart';

// ─── Mock que lanza excepción configurable ────────────────────────────────────

class MockPagoRepositoryConError implements PagoRepository {
  final String mensajeError;

  MockPagoRepositoryConError(this.mensajeError);

  @override
  Future<void> insertarPago(Pago pago) async =>
      throw Exception(mensajeError);

  @override
  Future<List<Pago>> getPagosPorAlumno(
    String idAlumno, {
    int? anio,
    int? mes,
  }) async => [];

  @override
  Future<Pago?> getUltimoPago(String idAlumno) async => null;

  @override
  Future<void> updatePago(Pago pago) async {}

  @override
  Future<void> deletePago(String idPago) async {}
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockPagoRepository mockPagoRepository;
  late MockPrecioRepository mockPrecioRepository;
  late MockDescuentoRepository mockDescuentoRepository;

  final alumnoPrueba = Alumno(idAlumno: 'abc', nombre: 'Juan', apellido: 'Perez');

  setUp(() async {
    await initializeDateFormatting('es', null);
    mockPagoRepository = MockPagoRepository();
    mockPrecioRepository = MockPrecioRepository();
    mockDescuentoRepository = MockDescuentoRepository();
  });

  Widget buildWidget({PagoRepository? pagoRepo}) {
    return ProviderScope(
      overrides: [
        pagoRepositoryProvider.overrideWithValue(pagoRepo ?? mockPagoRepository),
        precioRepositoryProvider.overrideWithValue(mockPrecioRepository),
        descuentoRepositoryProvider.overrideWithValue(mockDescuentoRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => PagoForm(alumno: alumnoPrueba),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> abrirForm(WidgetTester tester, {PagoRepository? pagoRepo}) async {
    await tester.pumpWidget(buildWidget(pagoRepo: pagoRepo));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> tocarConfirmar(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Confirmar Pago'));
    await tester.tap(find.text('Confirmar Pago'));
    await tester.pumpAndSettle();
  }

  // ── Tests base ─────────────────────────────────────────────────────────────

  testWidgets('debe cargar y mostrar los planes disponibles', (tester) async {
    await abrirForm(tester);
    expect(find.text('Registrar Pago'), findsOneWidget);
    expect(find.text('Personalizado'), findsOneWidget);
  });

  testWidgets('por default no debe venir seleccionado el plan Personalizado', (tester) async {
    await abrirForm(tester);

    final chip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Personalizado'),
    );

    expect(chip.selected, isFalse);
  });

  testWidgets('guarda el pago correctamente cuando es un plan normal', (tester) async {
    await abrirForm(tester);
    await tester.ensureVisible(find.text('3 días'));
    await tester.tap(find.text('3 días'));
    await tester.pumpAndSettle();
    await tocarConfirmar(tester);

    final ultimoPago = await mockPagoRepository.getUltimoPago('abc');
    expect(ultimoPago, isNotNull);
    expect(ultimoPago!.monto, 15000);
    expect(ultimoPago.cantidadDias, 3);
    expect(ultimoPago.medioDePago, 'Efectivo');
  });

  // ── Error de comentario inline ─────────────────────────────────────────────

  testWidgets(
    'error de comentario aparece inline debajo del campo, no como snackbar',
    (tester) async {
      await abrirForm(tester);

      await tester.tap(find.text('Personalizado'));
      await tester.pumpAndSettle();
      await tocarConfirmar(tester);

      // El error debe aparecer en el árbol de widgets (inline)
      expect(
        find.text('El comentario es obligatorio para pagos personalizados.'),
        findsOneWidget,
      );

      // NO debe haber un SnackBar con ese mensaje
      expect(find.byType(SnackBar), findsNothing);
    },
  );

  testWidgets(
    'el campo comentario muestra borde rojo cuando hay error de comentario',
    (tester) async {
      await abrirForm(tester);
      await tester.tap(find.text('Personalizado'));
      await tester.pumpAndSettle();
      await tocarConfirmar(tester);

      // Debe existir un OutlineInputBorder con color rojo
      // Lo verificamos buscando el widget de error que aparece debajo
      expect(
        find.text('El comentario es obligatorio para pagos personalizados.'),
        findsOneWidget,
      );

      // Al escribir en el campo el error debe desaparecer
      final comentariosField = find.byType(TextFormField).last;
      await tester.ensureVisible(comentariosField);
      await tester.enterText(comentariosField, 'Un comentario');
      await tester.pump();

      expect(
        find.text('El comentario es obligatorio para pagos personalizados.'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'error de comentario desaparece al escribir en el campo',
    (tester) async {
      await abrirForm(tester);
      await tester.tap(find.text('Personalizado'));
      await tester.pumpAndSettle();
      await tocarConfirmar(tester);

      expect(
        find.text('El comentario es obligatorio para pagos personalizados.'),
        findsOneWidget,
      );

      // Escribir en el campo de comentarios
      final comentariosField = find.byType(TextFormField).last;
      await tester.enterText(comentariosField, 'un comentario');
      await tester.pump();

      expect(
        find.text('El comentario es obligatorio para pagos personalizados.'),
        findsNothing,
      );
    },
  );

  // ── Error de unicidad (pago duplicado en el mes) ───────────────────────────

  testWidgets(
    'error de unicidad aparece con key error-fecha-duplicada (debajo del selector de fecha)',
    (tester) async {
      final repoConError = MockPagoRepositoryConError(
        'duplicate key value violates unique constraint (23505)',
      );
      await abrirForm(tester, pagoRepo: repoConError);

      await tester.ensureVisible(find.text('3 días'));
      await tester.tap(find.text('3 días'));
      await tester.pumpAndSettle();

      await tocarConfirmar(tester);

      // El error de unicidad debe usar la key 'error-fecha-duplicada'
      expect(find.byKey(const Key('error-fecha-duplicada')), findsOneWidget);

      // NO debe usar la key 'error-servidor-generico' (esa es para errores genéricos)
      expect(find.byKey(const Key('error-servidor-generico')), findsNothing);

      // El mensaje sigue siendo claro
      expect(
        find.textContaining('ya tiene un pago registrado para ese mes'),
        findsOneWidget,
      );

      // No hay SnackBar
      expect(find.byType(SnackBar), findsNothing);

      // El diálogo permanece abierto
      expect(find.text('Registrar Pago'), findsOneWidget);
    },
  );

  testWidgets(
    'error de unicidad detecta keyword "unique" en el mensaje',
    (tester) async {
      final repoConError = MockPagoRepositoryConError('unique constraint violated');
      await abrirForm(tester, pagoRepo: repoConError);

      await tester.ensureVisible(find.text('3 días'));
      await tester.tap(find.text('3 días'));
      await tester.pumpAndSettle();

      await tocarConfirmar(tester);

      expect(find.byKey(const Key('error-fecha-duplicada')), findsOneWidget);
      expect(
        find.textContaining('ya tiene un pago registrado para ese mes'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'error de unicidad detecta keyword "duplicate" en el mensaje',
    (tester) async {
      final repoConError = MockPagoRepositoryConError('duplicate entry for this month');
      await abrirForm(tester, pagoRepo: repoConError);

      await tester.ensureVisible(find.text('3 días'));
      await tester.tap(find.text('3 días'));
      await tester.pumpAndSettle();

      await tocarConfirmar(tester);

      expect(find.byKey(const Key('error-fecha-duplicada')), findsOneWidget);
      expect(
        find.textContaining('ya tiene un pago registrado para ese mes'),
        findsOneWidget,
      );
    },
  );

  // ── Error genérico de servidor ─────────────────────────────────────────────

  testWidgets(
    'error genérico de servidor usa key error-servidor-generico (no la de fecha)',
    (tester) async {
      final repoConError = MockPagoRepositoryConError('Connection timeout');
      await abrirForm(tester, pagoRepo: repoConError);

      await tester.ensureVisible(find.text('3 días'));
      await tester.tap(find.text('3 días'));
      await tester.pumpAndSettle();

      await tocarConfirmar(tester);

      // Usa la key de error genérico (fondo del form)
      expect(find.byKey(const Key('error-servidor-generico')), findsOneWidget);

      // NO usa la key de fecha duplicada
      expect(find.byKey(const Key('error-fecha-duplicada')), findsNothing);

      expect(find.textContaining('Ocurrió un error al guardar'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);

      // El diálogo permanece abierto
      expect(find.text('Registrar Pago'), findsOneWidget);
    },
  );

  // ── Limpieza de errores ────────────────────────────────────────────────────

  testWidgets(
    'los errores del servidor se limpian al inicio de cada intento de guardar',
    (tester) async {
      final repoConError = MockPagoRepositoryConError('Network error');
      await abrirForm(tester, pagoRepo: repoConError);

      // Seleccionar plan y guardar → produce error de servidor
      await tester.ensureVisible(find.text('3 días'));
      await tester.tap(find.text('3 días'));
      await tester.pumpAndSettle();
      await tocarConfirmar(tester);

      // Verificar que el error aparece
      expect(find.textContaining('Ocurrió un error al guardar'), findsOneWidget);

      // Al intentar guardar de nuevo, el error se limpia primero (setState al inicio de _guardarPago)
      // y vuelve a aparecer (porque el mock sigue fallando)
      await tocarConfirmar(tester);
      // El error de servidor sigue ahí porque el repo sigue fallando
      expect(find.textContaining('Ocurrió un error al guardar'), findsOneWidget);
    },
  );

  testWidgets(
    'errores de comentario se limpian al intentar guardar nuevamente con comentario',
    (tester) async {
      await abrirForm(tester);
      await tester.tap(find.text('Personalizado'));
      await tester.pumpAndSettle();

      // Primera pasada: sin comentario → error
      await tocarConfirmar(tester);
      expect(
        find.text('El comentario es obligatorio para pagos personalizados.'),
        findsOneWidget,
      );

      // Completar comentario y monto
      final montoField = find.byType(TextFormField).first;
      await tester.enterText(montoField, '5000');

      final diasField = find.byType(TextFormField).at(1);
      await tester.enterText(diasField, '30');

      final comentariosField = find.byType(TextFormField).last;
      await tester.enterText(comentariosField, 'Pago del mes');
      await tester.pump();

      // El error ya desapareció al escribir
      expect(
        find.text('El comentario es obligatorio para pagos personalizados.'),
        findsNothing,
      );

      // Guardar exitosamente
      await tocarConfirmar(tester);

      final ultimoPago = await mockPagoRepository.getUltimoPago('abc');
      expect(ultimoPago, isNotNull);
      expect(ultimoPago!.comentarios, 'Pago del mes');
    },
  );
}
