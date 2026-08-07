import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/presentacion/forms/exercise_form.dart';
import '../../mocks/mock_exercise_repository.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';
import 'package:le_groupe_gym/core/app_failure.dart';

class _FailingExerciseRepository implements ExerciseRepository {
  @override
  Future<int> createExercise({
    required String nombre,
    required List<int> categoriaIds,
    String? id,
  }) async => throw const DuplicateFailure('Ya existe un ejercicio con este nombre.');

  @override
  Future<List<Ejercicio>> getExercises() async => [];
}

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

    Widget createWidgetUnderTest({
      VoidCallback? onCancelar,
      Function(Map<String, dynamic>)? onGuardar,
      ExerciseRepository? exerciseRepository,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AddExerciseForm(
            categorias: mockCategorias,
            onCancelar: onCancelar ?? () {},
            onGuardar: onGuardar ?? (_) {},
            exerciseRepository: exerciseRepository ?? MockExerciseRepository(),
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

    testWidgets(
      'detecta como duplicado un nombre que solo cambia mayúsculas o espacios',
      (tester) async {
        var guardados = 0;
        await tester.pumpWidget(
          createWidgetUnderTest(onGuardar: (_) => guardados++),
        );

        await tester.enterText(
          find.byKey(const Key('exercise_name_field')),
          '  press de banca  ',
        );
        await tester.pump();
        await tester.tap(find.text('Guardar Ejercicio'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('error-ejercicio')), findsOneWidget);
        expect(
          find.text('Ya existe un ejercicio con este nombre.'),
          findsOneWidget,
        );
        expect(guardados, isZero);
      },
    );

    testWidgets(
      'muestra el error de ejercicio duplicado inline y lo limpia al editar',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            exerciseRepository: _FailingExerciseRepository(),
          ),
        );

        await tester.enterText(
          find.byKey(const Key('exercise_name_field')),
          'Press de Banca',
        );
        await tester.pump();
        await tester.tap(find.text('Guardar Ejercicio'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('error-ejercicio')), findsOneWidget);
        expect(
          find.text('Ya existe un ejercicio con este nombre.'),
          findsOneWidget,
        );

        await tester.enterText(
          find.byKey(const Key('exercise_name_field')),
          'Press con Mancuernas',
        );
        await tester.pump();

        expect(find.byKey(const Key('error-ejercicio')), findsNothing);
      },
    );
  });
}
