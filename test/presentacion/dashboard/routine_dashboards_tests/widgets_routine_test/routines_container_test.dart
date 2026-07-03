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
    }) {
      return MaterialApp(
        home: Scaffold(
          body: RutinasPanel(
            rutinas: rutinas ?? mockRutinas,
            onVerDetalle: onVerDetalle ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('debe mostrar el título del panel', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Últimas rutinas realizadas'), findsOneWidget);
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

    testWidgets('debe llamar onVerDetalle al presionar el botón ver detalle', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      Rutina? rutinaSeleccionada;
      await tester.pumpWidget(
        createWidgetUnderTest(onVerDetalle: (r) => rutinaSeleccionada = r),
      );

      // Act
      await tester.tap(find.byIcon(Icons.arrow_forward_ios).first);
      await tester.pump();

      // Assert
      expect(rutinaSeleccionada, isNotNull);
      expect(rutinaSeleccionada!.idRutina, 1);

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
