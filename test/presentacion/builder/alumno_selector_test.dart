import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import '../../mocks/mock_alumno_repository.dart';

void main() {
  group('AlumnoSelector Widget Tests', () {
    late MockAlumnoRepository mockRepo;

    setUp(() {
      mockRepo = MockAlumnoRepository();
    });

    testWidgets('debe mostrar el hint cuando no hay alumno seleccionado', (
      tester,
    ) async {
      // Arrange
      Alumno? seleccionado;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlumnoSelector(
              alumnoRepository: mockRepo,
              alumnoSeleccionado: seleccionado,
              onAlumnoChanged: (alumno) => seleccionado = alumno,
            ),
          ),
        ),
      );

      // Act + Assert
      expect(find.text('Seleccionar alumno...'), findsOneWidget);
    });

    testWidgets('debe mostrar el nombre completo del alumno seleccionado', (
      tester,
    ) async {
      // Arrange
      final alumnoSeleccionado = Alumno(
        idAlumno: 'abc-123',
        nombre: 'Juan',
        apellido: 'Pérez',
        mail: 'juan@mail.com',
        aplicaDescuento: false,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlumnoSelector(
              alumnoRepository: mockRepo,
              alumnoSeleccionado: alumnoSeleccionado,
              onAlumnoChanged: (_) {},
            ),
          ),
        ),
      );

      // Act + Assert
      expect(find.text('Juan Pérez'), findsOneWidget);
    });

    testWidgets('debe mostrar sugerencias al escribir y seleccionar una', (
      tester,
    ) async {
      // Arrange
      Alumno? resultado;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlumnoSelector(
              alumnoRepository: mockRepo,
              alumnoSeleccionado: null,
              onAlumnoChanged: (alumno) => resultado = alumno,
            ),
          ),
        ),
      );

      // Act — type a query and wait for debounce + async
      await tester.enterText(find.byType(TextField), 'Mar');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Assert — 'María García' should appear in the overlay
      expect(find.text('María García'), findsOneWidget);

      // Act — tap on the suggestion
      await tester.tap(find.text('María García'));
      await tester.pumpAndSettle();

      // Assert
      expect(resultado?.idAlumno, 'def-456');
    });
  });
}
