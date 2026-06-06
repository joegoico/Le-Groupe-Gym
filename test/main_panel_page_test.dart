import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/pages/main_panel_page.dart';
import 'package:le_groupe_gym/presentacion/builder/exercise_sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_workspace.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'mocks/mock_exercise_repository.dart';
import 'mocks/mock_routine_repository.dart';
import 'mocks/mock_alumno_repository.dart';
import 'mocks/mock_category_exercise_repository.dart';

void main() {
  group('MainPanelPage Widget Tests - Flujo Asíncrono AAA', () {
    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          exerciseRepositoryProvider.overrideWithValue(
            MockExerciseRepository(),
          ),
          routineRepositoryProvider.overrideWithValue(MockRoutineRepository()),
          alumnoRepositoryProvider.overrideWithValue(MockAlumnoRepository()),
          categoryExerciseRepositoryProvider.overrideWithValue(
            MockCategoryExerciseRepository(),
          ), // 👈
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MainPanelPage(),
        ),
      );
    }

    testWidgets('Debe mostrar inicialmente el indicador de carga circular', (
      WidgetTester tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ExcerciseSidebar), findsNothing);
      expect(find.byType(RoutineWorkspace), findsNothing);

      await tester.pumpAndSettle();
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets(
      'Debe remover el loader y desplegar el panel completo tras resolver el repositorio',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(const Duration(milliseconds: 500));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(ExcerciseSidebar), findsOneWidget);
        expect(find.byType(RoutineWorkspace), findsOneWidget);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
    testWidgets(
      'debe mostrar snackbar al intentar agregar ejercicio duplicado',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(const Duration(milliseconds: 500));

        // Act — agregamos el mismo ejercicio dos veces via el botón +
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pump();
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pump();

        // Assert
        expect(
          find.text('Ese ejercicio ya está en el bloque activo.'),
          findsOneWidget,
        );

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
  }); // ← cierre del group
}
