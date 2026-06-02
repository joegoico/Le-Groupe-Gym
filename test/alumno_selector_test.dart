import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/alumno_selector.dart';

void main() {
  group('AlumnoSelector Widget Tests', () {
    final mockAlumnos = [
      Alumno(idAlumno: 'abc-123', nombre: 'Juan', apellido: 'Pérez', aplicaDescuento: false),
      Alumno(idAlumno: 'def-456', nombre: 'María', apellido: 'García', aplicaDescuento: true),
    ];
    testWidgets('debe mostrar el hint cuando no hay alumno seleccionado', (tester) async {
      // Arrange
      Alumno? seleccionado;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlumnoSelector(
              alumnos: mockAlumnos,
              alumnoSeleccionado: seleccionado,
              onAlumnoChanged: (alumno) => seleccionado = alumno,
            ),
          ),
        ),
      );

      // Act + Assert
      expect(find.text('Seleccionar alumno...'), findsOneWidget);
    });

    testWidgets('debe mostrar el nombre completo del alumno seleccionado', (tester) async {
      // Arrange
      final alumnoSeleccionado = mockAlumnos.first;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlumnoSelector(
              alumnos: mockAlumnos,
              alumnoSeleccionado: alumnoSeleccionado,
              onAlumnoChanged: (_) {},
            ),
          ),
        ),
      );

      // Act + Assert
      expect(find.text('Juan Pérez'), findsOneWidget);
    });

    testWidgets('debe disparar onAlumnoChanged al seleccionar un alumno', (tester) async {
      // Arrange
      Alumno? resultado;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlumnoSelector(
              alumnos: mockAlumnos,
              alumnoSeleccionado: null,
              onAlumnoChanged: (alumno) => resultado = alumno,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('María García').last);
      await tester.pumpAndSettle();

      // Assert
      expect(resultado?.idAlumno, 'def-456');
    });
  });
}
