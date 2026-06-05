import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/presentacion/builder/exercise_sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_builder_controller.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_workspace.dart';
import 'mocks/mock_category_exercise_repository.dart';
import 'mocks/mock_exercise_repository.dart';

void main() {
  group('RoutineWorkspace Widget Tests - Patrón AAA', () {
    late RoutineBuilderController controller;
    late Ejercicio mockEjercicio;

    setUp(() {
      controller = RoutineBuilderController();
      mockEjercicio = Ejercicio(
        idEjercicio: 1,
        nombre: 'Dominadas',
        categorias: [],
      );
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(body: RoutineWorkspace(controller: controller)),
      );
    }

    Widget createPanelUnderTest({required List<Ejercicio> catalogo}) {
      return MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Row(
                children: [
                  ExcerciseSidebar(
                    allExercises: catalogo,
                    controller: controller,
                    onAddExercise: (ejercicio) {
                      controller.handleExerciseFromSidebar(ejercicio);
                    },
                    exerciseRepository: MockExerciseRepository(),
                    categoryExerciseRepository:
                        MockCategoryExerciseRepository(),
                  ),
                  Expanded(child: RoutineWorkspace(controller: controller)),
                ],
              ),
            );
          },
        ),
      );
    }

    testWidgets(
      'debe mostrar el estado vacío si el controlador no tiene ejercicios',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act + Assert
        expect(find.text('Zona de Armado de Rutinas'), findsOneWidget);
        expect(
          find.text('Creá un bloque y agregá ejercicios desde la librería'),
          findsOneWidget,
        );
        expect(find.text('Agregar bloque'), findsOneWidget);
        expect(find.text('Limpiar Todo'), findsNothing);
        // Guardar Rutina ya no vive acá — está en MainPanelPage
        expect(find.text('Guardar Rutina'), findsNothing);
      },
    );

    testWidgets(
      'debe mostrar la tarjeta del ejercicio y el botón limpiar si hay items',
      (WidgetTester tester) async {
        // Arrange
        controller.addExercise(mockEjercicio);

        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Assert
        expect(find.text('Nueva Rutina de Entrenamiento'), findsOneWidget);
        expect(find.textContaining('1 ejercicios'), findsOneWidget);
        expect(find.textContaining('1 bloques'), findsOneWidget);
        expect(find.text('Dominadas'), findsOneWidget);
        expect(find.text('Limpiar Todo'), findsOneWidget);
        // Guardar Rutina ya no vive acá
        expect(find.text('Guardar Rutina'), findsNothing);
      },
    );

    testWidgets('debe llamar a clearRoutine al presionar Limpiar Todo', (
      WidgetTester tester,
    ) async {
      // Arrange
      controller.addExercise(mockEjercicio);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Limpiar Todo'));
      await tester.pump();

      // Assert
      expect(controller.currentRoutine, isEmpty);
    });
    testWidgets('debe reordenar ejercicios al hacer drag & drop', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      final ejercicio2 = Ejercicio(
        idEjercicio: 2,
        nombre: 'Sentadilla',
        categorias: [],
      );
      controller.addExercise(mockEjercicio); // índice 0: Dominadas
      controller.addExercise(ejercicio2); // índice 1: Sentadilla

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Dominadas'), findsOneWidget);
      expect(find.text('Sentadilla'), findsOneWidget);
      expect(find.byType(ReorderableListView), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets(
      'al presionar Combinar debe indicar elegir desde la sidebar e inputs independientes',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        final ejercicioAcoplable = Ejercicio(
          idEjercicio: 2,
          nombre: 'Remo con Barra',
          categorias: [],
        );
        controller.addExercise(mockEjercicio);

        // Act
        await tester.pumpWidget(
          createPanelUnderTest(catalogo: [mockEjercicio, ejercicioAcoplable]),
        );
        await tester.tap(find.text('Combinar'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('librería'), findsWidgets);
        expect(find.byIcon(Icons.link), findsWidgets);
        expect(find.byType(DropdownMenu<Ejercicio>), findsNothing);
        expect(find.byKey(const Key('slot_series_0_0_0')), findsOneWidget);
        expect(find.byKey(const Key('slot_reps_0_0_0')), findsOneWidget);
        expect(find.byKey(const Key('slot_series_0_0_1')), findsOneWidget);
        expect(find.byKey(const Key('slot_reps_0_0_1')), findsOneWidget);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );

    testWidgets(
      'debe acoplar el ejercicio elegido desde la sidebar con inputs independientes',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        final ejercicioAcoplable = Ejercicio(
          idEjercicio: 2,
          nombre: 'Remo con Barra',
          categorias: [],
        );
        controller.addExercise(mockEjercicio);

        await tester.pumpWidget(
          createPanelUnderTest(catalogo: [mockEjercicio, ejercicioAcoplable]),
        );

        // Act
        await tester.tap(find.text('Combinar'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.link).last);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Dominadas'), findsWidgets);
        expect(find.text('Remo con Barra'), findsWidgets);
        expect(find.text('Combinar'), findsNothing);
        expect(find.byKey(const Key('slot_series_0_0_0')), findsOneWidget);
        expect(find.byKey(const Key('slot_series_0_0_1')), findsOneWidget);
        expect(controller.currentRoutine.first.esSuperserie, isTrue);
        expect(controller.currentRoutine.first.cantidadEjercicios, 2);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );

    testWidgets('debe mostrar Bloque 1 al presionar Agregar bloque', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Bloque 1'), findsNothing);

      // Act
      await tester.tap(find.text('Agregar bloque'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Bloque 1'), findsOneWidget);
    });

    testWidgets('debe mover ejercicio a otro bloque desde el menú', (
      WidgetTester tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      final ejercicio2 = Ejercicio(
        idEjercicio: 2,
        nombre: 'Sentadilla',
        categorias: [],
      );

      controller.addBlock(nombre: 'Bloque A');
      controller.addBlock(nombre: 'Bloque B');
      controller.addExercise(mockEjercicio, blockIndex: 0);
      controller.addExercise(ejercicio2, blockIndex: 0);

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.byIcon(Icons.swap_horiz).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bloque B').last);
      await tester.pumpAndSettle();

      // Assert — se movió Dominadas (primera tarjeta) al Bloque B
      expect(controller.bloques[0].ejercicios.length, 1);
      expect(controller.bloques[1].ejercicios.length, 1);
      expect(
        controller.bloques[0].ejercicios.first.ejercicio.nombre,
        'Sentadilla',
      );
      expect(
        controller.bloques[1].ejercicios.first.ejercicio.nombre,
        'Dominadas',
      );

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
