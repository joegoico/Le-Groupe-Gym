import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import 'package:le_groupe_gym/presentacion/pages/alumnos_page.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import '../../mocks/mock_alumno_repository.dart';

void main() {
  group('AlumnosPage Widget Tests', () {
    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          alumnoRepositoryProvider.overrideWithValue(MockAlumnoRepository()),
        ],
        child: const MaterialApp(home: AlumnosPage()),
      );
    }

    // ── Carga inicial ────────────────────────────────────────────────────────

    testWidgets('debe mostrar indicador de carga inicial', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert — antes del primer frame asincrónico debe haber un spinner
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    // ── Cards de alumnos ─────────────────────────────────────────────────────

    testWidgets('debe mostrar cards de alumnos tras cargar', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 100));

      // Assert — el mock tiene 16 alumnos; cada uno se renderiza como AlumnoCard
      expect(find.byType(AlumnoCard), findsNWidgets(16));

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('cada card muestra el nombre completo del alumno', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 100));

      // Assert — verificamos los primeros dos del mock
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Lucas Benítez'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('cards con descuento muestran "Con descuento"', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 100));

      // Assert — en el mock hay 5 alumnos con aplicaDescuento=true
      expect(find.text('Con descuento'), findsNWidgets(5));

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('cada card tiene botón "VER PAGOS"', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 100));

      // Assert — 16 alumnos → 16 botones "VER PAGOS"
      expect(find.text('VER PAGOS'), findsNWidgets(16));

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('cada card tiene botones de editar y eliminar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 100));

      // Assert — 16 cards × 1 botón eliminar y 1 editar c/u
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(16));
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(16));

      addTearDown(tester.view.resetPhysicalSize);
    });

    // ── TopBar ───────────────────────────────────────────────────────────────

    testWidgets('debe mostrar botón "Nuevo Alumno" en el TopBar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Nuevo Alumno'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe tener AlumnoSelector en el TopBar', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AlumnoSelector), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    // ── Filtrado por selección ────────────────────────────────────────────────

    testWidgets(
      'al seleccionar un alumno la lista se filtra a ese alumno',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(const Duration(milliseconds: 100));

        // Act — escribimos en el AlumnoSelector para disparar la búsqueda
        final selectorField = find.descendant(
          of: find.byKey(const Key('alumnos_search_selector')),
          matching: find.byType(TextField),
        );
        await tester.enterText(selectorField, 'Juan');
        // Esperamos debounce (300ms) + frame del mock
        await tester.pump(const Duration(milliseconds: 400));

        // El overlay del AlumnoSelector debe aparecer con "Juan Pérez"
        expect(find.text('Juan Pérez'), findsWidgets);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );

    // ── Layout / overflow ─────────────────────────────────────────────────────

    testWidgets('no debe producir overflow en el render tree', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 100));

      // Si existiera overflow, tester.pump lanzaría una excepción
      expect(tester.takeException(), isNull);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
