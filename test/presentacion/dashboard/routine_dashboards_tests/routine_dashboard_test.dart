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
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SolicitudesPanel), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar el panel de rutinas tras cargar', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(RutinasPanel), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar la TopBar con título Rutinas', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Rutinas'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe abrir el formulario al registrar una solicitud', (
      tester,
    ) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registrar solicitud'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AddSolicitudRutinaForm), findsOneWidget);
      expect(find.text('Nueva Solicitud de Rutina'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe actualizar el contador luego de guardar una solicitud', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('2 Rutinas Pendientes'), findsOneWidget);

      await tester.tap(find.text('Registrar solicitud'));
      await tester.pumpAndSettle();

      final alumnoField = find
          .descendant(
            of: find.byType(AddSolicitudRutinaForm),
            matching: find.byType(TextField),
          )
          .first;

      await tester.enterText(alumnoField, 'Juan');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // 👇 Juan Pérez se muestra en un Overlay (fuera del subárbol del formulario).
      // Pueden existir 2 instancias (overlay + chip de selección), tomamos .last
      // que corresponde al ítem del overlay insertado al final del árbol.
      await tester.tap(find.text('Juan Pérez').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('solicitud_rutina_name_field')),
        'Hipertrofia',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('guardar_solicitud_button')));
      await tester.pumpAndSettle();

      expect(find.text('3 Rutinas Pendientes'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
