import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_dashbord_page.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_widgets/solicitudes_panel.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_widgets/rutinas_panel.dart';
import 'package:le_groupe_gym/presentacion/forms/solicitud_rutina_form.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import '../../../mocks/mock_solicitud_rutina_repository.dart';
import '../../../mocks/mock_routine_repository.dart';
import '../../../mocks/mock_alumno_repository.dart';
import '../../../mocks/mock_pago_repository.dart';
import '../../../mocks/mock_deudor_repository.dart';

void main() {
  group('RutinasDashboardPage Widget Tests', () {
    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          solicitudRutinaRepositoryProvider.overrideWithValue(
            MockSolicitudRutinaRepository(),
          ),
          routineRepositoryProvider.overrideWithValue(MockRoutineRepository()),
          alumnoRepositoryProvider.overrideWithValue(MockAlumnoRepository()),
          pagoRepositoryProvider.overrideWithValue(MockPagoRepository()),
          deudorRepositoryProvider.overrideWithValue(MockDeudorRepository()),
        ],
        child: const MaterialApp(home: RutinasDashboardPage()),
      );
    }

    testWidgets('debe mostrar el indicador de carga inicial', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar el panel de solicitudes tras cargar', (
      tester,
    ) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      // Use pump(duration) instead of pumpAndSettle() to avoid the infinite
      // semantics loop caused by CompositedTransformTarget in AlumnoSelector.
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(SolicitudesPanel), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar el panel de rutinas tras cargar', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      // Use pump(duration) instead of pumpAndSettle() to avoid the infinite
      // semantics loop caused by CompositedTransformTarget in AlumnoSelector.
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(RutinasPanel), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar la TopBar con título Rutinas', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      // Use pump(duration) instead of pumpAndSettle() to avoid the infinite
      // semantics loop caused by CompositedTransformTarget in AlumnoSelector.
      await tester.pump(const Duration(seconds: 1));

      // Assert
      // 'Rutinas' aparece en el ítem del Sidebar y en el título del TopBar
      expect(find.text('Rutinas'), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe abrir el formulario al registrar una solicitud', (
      tester,
    ) async {
      // 1. Configurar tamaño (SIEMPRE primero)
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      // 2. Registrar el reset de inmediato por si el test falla
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Registrar solicitud'));

      // 3. CAMBIO CLAVE: En lugar de pumpAndSettle, usamos un pump repetido o con duración
      // Esto evita que si hay un loader, animación o dropdown abierto que mantenga
      // tareas pendientes en el Scheduler, el test crashee.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byType(AddSolicitudRutinaForm), findsOneWidget);
      expect(find.text('Nueva Solicitud de Rutina'), findsOneWidget);
    });

    testWidgets('debe actualizar el contador luego de guardar una solicitud', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      // Use pump(duration) instead of pumpAndSettle() to avoid the infinite
      // semantics loop caused by CompositedTransformTarget in AlumnoSelector.
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('2 Rutinas Pendientes'), findsOneWidget);

      await tester.tap(find.text('Registrar solicitud'));
      await tester.pump(const Duration(milliseconds: 300));

      final alumnoField = find
          .descendant(
            of: find.byType(AddSolicitudRutinaForm),
            matching: find.byType(TextField),
          )
          .first;

      await tester.enterText(alumnoField, 'Juan');
      // Wait for debounce (300ms) + a bit more so the overlay appears.
      await tester.pump(const Duration(milliseconds: 400));

      // 👇 Juan Pérez se muestra en un Overlay (fuera del subárbol del formulario).
      // Pueden existir 2 instancias (overlay + chip de selección), tomamos .last
      // que corresponde al ítem del overlay insertado al final del árbol.
      await tester.tap(find.text('Juan Pérez').last);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.enterText(
          find.byKey(const Key('solicitud_rutina_name_field')),
          'Rutina Test',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      
      // Since the student has no payments (MockPagoRepository is empty), it shows the warning.
      // We must tap 'Continuar' to proceed.
      expect(find.text('Advertencia'), findsOneWidget);
      await tester.tap(find.text('Continuar').last);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('3 Rutinas Pendientes'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
