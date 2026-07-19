import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_widgets/rutinas_panel.dart';

void main() {
  group('RutinasPanel Widget Tests', () {
    final mockAlumno1 = Alumno(
      idAlumno: 'abc-123',
      nombre: 'Juan',
      apellido: 'Pérez',
      aplicaDescuento: false,
    );
    final mockAlumno2 = Alumno(
      idAlumno: 'def-456',
      nombre: 'María',
      apellido: 'García',
      aplicaDescuento: false,
    );

    final mockRutinas = [
      (
        rutina: Rutina(
          idRutina: 1,
          nombre: 'Hipertrofia - Pecho y Tríceps',
          idAlumno: 'abc-123',
          fechaCreacion: DateTime(2026, 1, 1, 10, 30),
        ),
        alumno: mockAlumno1,
      ),
      (
        rutina: Rutina(
          idRutina: 2,
          nombre: 'Acondicionamiento HIIT',
          idAlumno: 'def-456',
          fechaCreacion: DateTime(2026, 1, 1, 8, 15),
        ),
        alumno: mockAlumno2,
      ),
    ];

    Widget createWidgetUnderTest({
      List<({Rutina rutina, Alumno alumno})>? rutinas,
      Function(Rutina)? onVerDetalle,
      Function(Rutina)? onEditarRutina,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: RutinasPanel(
            rutinas: rutinas ?? mockRutinas,
            onVerDetalle: onVerDetalle ?? (_) {},
            onEditarRutina: onEditarRutina ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('debe mostrar el título del panel', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Últimas 10 realizadas'), findsOneWidget);
    });

    testWidgets('debe mostrar el nombre de cada rutina', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Hipertrofia - Pecho y Tríceps'), findsOneWidget);
      expect(find.text('Acondicionamiento HIIT'), findsOneWidget);
    });

    testWidgets('debe mostrar el nombre del alumno de cada rutina', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('María García'), findsOneWidget);
    });

    testWidgets('debe mostrar botón Ver en cada rutina', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Ver'), findsNWidgets(2));

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar botón editar en cada rutina', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe llamar onVerDetalle al presionar Ver', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      Rutina? rutinaSeleccionada;
      await tester.pumpWidget(
        createWidgetUnderTest(onVerDetalle: (r) => rutinaSeleccionada = r),
      );

      // Act
      await tester.tap(find.text('Ver').first);
      await tester.pump();

      // Assert
      expect(rutinaSeleccionada, isNotNull);
      expect(rutinaSeleccionada!.idRutina, 1);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe llamar onEditarRutina al presionar el lápiz', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      Rutina? rutinaEditada;
      await tester.pumpWidget(
        createWidgetUnderTest(onEditarRutina: (r) => rutinaEditada = r),
      );

      // Act
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pump();

      // Assert
      expect(rutinaEditada, isNotNull);
      expect(rutinaEditada!.idRutina, 1);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar mensaje si no hay rutinas', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest(rutinas: []));

      // Assert
      expect(find.text('No hay rutinas registradas'), findsOneWidget);
    });
  });
}
