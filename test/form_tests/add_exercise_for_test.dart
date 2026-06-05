import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/presentacion/forms/exercise_form.dart';
import '../mocks/mock_exercise_repository.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';

void main() {
  group('AddExerciseForm Tests', () {
    final mockCategorias = [
      CategoriaEjercicio(
        idCategoria: 1,
        nombre: 'Pecho',
        tipo: 'grupo_muscular',
      ),
      CategoriaEjercicio(
        idCategoria: 2,
        nombre: 'Espalda',
        tipo: 'grupo_muscular',
      ),
      CategoriaEjercicio(
        idCategoria: 3,
        nombre: 'Pectoral Mayor',
        tipo: 'subgrupo',
      ),
    ];

    final mockEjercicios = [
      Ejercicio(idEjercicio: 1, nombre: 'Press de Banca Plano', categorias: []),
      Ejercicio(
        idEjercicio: 2,
        nombre: 'Press de Banca Inclinado',
        categorias: [],
      ),
      Ejercicio(
        idEjercicio: 3,
        nombre: 'Press de Banca Declinado',
        categorias: [],
      ),
    ];

    Widget createWidgetUnderTest({
      VoidCallback? onCancelar,
      Function(Map<String, dynamic>)? onGuardar,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AddExerciseForm(
            categorias: mockCategorias,
            onCancelar: onCancelar ?? () {},
            onGuardar: onGuardar ?? (_) {},
            exerciseRepository: MockExerciseRepository(),
          ),
        ),
      );
    }

    testWidgets('debe mostrar el campo de nombre del ejercicio', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byKey(const Key('exercise_name_field')), findsOneWidget);
    });

    testWidgets('debe mostrar el selector de categorías', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Pecho'), findsOneWidget);
      expect(find.text('Espalda'), findsOneWidget);
    });

    testWidgets('debe mostrar los botones Cancelar y Guardar', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Guardar Ejercicio'), findsOneWidget);
    });

    testWidgets('debe llamar onCancelar al presionar Cancelar', (tester) async {
      // Arrange
      bool cancelado = false;
      await tester.pumpWidget(
        createWidgetUnderTest(onCancelar: () => cancelado = true),
      );

      // Act
      await tester.tap(find.text('Cancelar'));
      await tester.pump();

      // Assert
      expect(cancelado, isTrue);
    });

    testWidgets('el botón Guardar debe estar deshabilitado sin nombre', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final boton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Guardar Ejercicio'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(boton.onPressed, isNull);
    });

    testWidgets('el botón Guardar debe habilitarse al ingresar un nombre', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(
        find.byKey(const Key('exercise_name_field')),
        'Press de Banca',
      );
      await tester.pump();

      // Assert
      final boton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Guardar Ejercicio'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(boton.onPressed, isNotNull);
    });
  });
}
