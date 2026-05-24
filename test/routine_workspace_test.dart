import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/routine_builder_controller.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/routine_workspace.dart';

void main() {
  group('RoutineWorkspace Widget Tests - Patrón AAA', () {
    late RoutineBuilderController controller;
    late Ejercicio mockEjercicio;

    setUp(() {
      controller = RoutineBuilderController();
      mockEjercicio = Ejercicio(idEjercicio: 1, nombre: 'Dominadas', categorias: []);
    });

    // Helper base
    Widget createWidgetUnderTest({VoidCallback? onSave, VoidCallback? onRefresh}) {
      return MaterialApp(
        home: Scaffold(
          body: RoutineWorkspace(
            controller: controller,
            onRefresh: onRefresh ?? () {},
            onSave: onSave ?? () {},
          ),
        ),
      );
    }

    testWidgets('Debe mostrar el estado vacío si el controlador no tiene ejercicios', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      expect(find.text('Zona de Armado de Rutinas'), findsOneWidget);
      expect(find.text('Presioná el botón "+" en la librería de ejercicios para empezar'), findsOneWidget);
      expect(find.text('Limpiar Todo'), findsNothing);
      expect(find.text('Guardar Rutina'), findsNothing);
    });

    testWidgets('Debe mostrar la tarjeta del ejercicio y los botones de cabecera si hay items', (WidgetTester tester) async {
      // Arrange
      controller.addExercise(mockEjercicio);
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      expect(find.text('Nueva Rutina de Entrenamiento'), findsOneWidget);
      expect(find.text('1 ejercicios seleccionados'), findsOneWidget);
      expect(find.text('Dominadas'), findsOneWidget);
      expect(find.text('Limpiar Todo'), findsOneWidget);
      expect(find.text('Guardar Rutina'), findsOneWidget);
    });

    testWidgets('Debe llamar a clearRoutine al presionar Limpiar Todo', (WidgetTester tester) async {
      // Arrange
      controller.addExercise(mockEjercicio);
      bool refreshCalled = false;
      
      await tester.pumpWidget(createWidgetUnderTest(
        onRefresh: () => refreshCalled = true,
      ));

      // Act
      final botonLimpiar = find.text('Limpiar Todo');
      await tester.tap(botonLimpiar);
      await tester.pump();

      // Assert
      expect(controller.currentRoutine, isEmpty);
      expect(refreshCalled, isTrue);
    });

    // ==========================================
    // NUEVO TEST: BOTÓN GUARDAR
    // ==========================================
    testWidgets('Debe ejecutar onSave al presionar Guardar Rutina cuando hay ejercicios', (WidgetTester tester) async {
      // Arrange
      controller.addExercise(mockEjercicio);
      bool saveCalled = false;
      
      await tester.pumpWidget(createWidgetUnderTest(
        onSave: () => saveCalled = true,
      ));

      // Act
      final botonGuardar = find.text('Guardar Rutina');
      await tester.tap(botonGuardar);
      await tester.pump();

      // Assert
      expect(saveCalled, isTrue);
    });
  });
}