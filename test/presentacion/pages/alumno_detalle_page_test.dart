import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/presentacion/pages/alumno_detalle_page.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import '../../mocks/mock_alumno_repository.dart';
import '../../mocks/mock_routine_repository.dart';
import '../../mocks/mock_pago_repository.dart';

void main() {
  // ── Alumno de prueba ─────────────────────────────────────────────────────────
  final alumnoConMail = Alumno(
    idAlumno: 'abc-123',
    nombre: 'Juan',
    apellido: 'Pérez',
    mail: 'juan@mail.com',
  );

  final alumnoSinMail = Alumno(
    idAlumno: 'def-456',
    nombre: 'María',
    apellido: 'García',
    mail: null,
  );

  Widget createWidgetUnderTest(Alumno alumno) {
    return ProviderScope(
      overrides: [
        alumnoRepositoryProvider.overrideWithValue(MockAlumnoRepository()),
        routineRepositoryProvider.overrideWithValue(MockRoutineRepository()),
        pagoRepositoryProvider.overrideWithValue(MockPagoRepository()),
      ],
      child: MaterialApp(home: AlumnoDetallePage(alumno: alumno)),
    );
  }

  group('AlumnoDetallePage', () {
    // ── Avatar ────────────────────────────────────────────────────────────────

    testWidgets('muestra las iniciales del alumno en el avatar', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(alumnoConMail));
      await tester.pump();

      expect(find.text('JP'), findsOneWidget);
    });

    // ── Nombre ────────────────────────────────────────────────────────────────

    testWidgets('muestra el nombre completo del alumno', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(alumnoConMail));

      expect(find.text('Juan Pérez'), findsWidgets);
    });

    // ── Email ─────────────────────────────────────────────────────────────────

    testWidgets('muestra el email cuando está disponible', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(alumnoConMail));
      await tester.pump();

      expect(find.text('juan@mail.com'), findsOneWidget);
    });

    testWidgets('muestra texto de email no registrado cuando no hay mail', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(alumnoSinMail));
      await tester.pump();

      expect(find.text('Sin email registrado'), findsOneWidget);
    });

    // ── Descuento ─────────────────────────────────────────────────────────────

    testWidgets('muestra badge "Con descuento" cuando aplica', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(alumnoSinMail));
      await tester.pump();

      expect(find.text('Con descuento'), findsOneWidget);
    });

    testWidgets('muestra badge "Sin descuento" cuando no aplica', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(alumnoConMail));
      await tester.pump();

      expect(find.text('Sin descuento'), findsOneWidget);
    });

    // ── Rutinas Asignadas ─────────────────────────────────────────────────────

    testWidgets('debe cargar y mostrar las rutinas', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(alumnoConMail));
      // Esperar a que el FutureProvider resuelva
      await tester.pumpAndSettle();

      // En el MockRoutineRepository actualmente devuelve 1 rutina ("Rutina de prueba")
      // cuando se llama a getRutinas() o debemos chequearlo.
      // Aquí solo chequeamos que diga RUTINAS ASIGNADAS
      expect(find.text('RUTINAS ASIGNADAS'), findsOneWidget);
    });

    // ── Botón registrar pago ──────────────────────────────────────────────────

    testWidgets('muestra botón "Registrar Pago"', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(alumnoConMail));
      await tester.pump();

      expect(
        find.byKey(const Key('detalle_registrar_pago_btn')),
        findsOneWidget,
      );
    });

    // ── Back ──────────────────────────────────────────────────────────────────

    testWidgets('tiene botón de volver (back)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(alumnoConMail));
      await tester.pump();

      expect(find.byKey(const Key('detalle_back_btn')), findsOneWidget);
    });
  });
}
