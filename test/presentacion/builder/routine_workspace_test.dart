import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/presentacion/builder/exercise_sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_builder_controller.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_workspace.dart';
import '../../mocks/mock_category_exercise_repository.dart';
import '../../mocks/mock_exercise_repository.dart';

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
        home: Scaffold(
          body: RoutineWorkspace(
            controller: controller,
            notasController: TextEditingController(),
          ),
        ),
      );
    }

    Widget createPanelUnderTest({required List<Ejercicio> catalogo}) {
      return MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Row(
                children: [
                  SizedBox(
                    width: 400,
                    child: ExcerciseSidebar(
                      allExercises: catalogo,
                      controller: controller,
                      onAddExercise: (ejercicio) {
                        controller.handleExerciseFromSidebar(ejercicio);
                      },
                      exerciseRepository: MockExerciseRepository(),
                      categoryExerciseRepository:
                          MockCategoryExerciseRepository(),
                    ),
                  ),
                  Expanded(
                    child: RoutineWorkspace(
                      controller: controller,
                      notasController: TextEditingController(),
                    ),
                  ),
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
        expect(find.text('Agregá un día para empezar'), findsOneWidget); // 👈
        expect(find.text('Agregar día'), findsOneWidget); // 👈
        expect(find.text('Limpiar'), findsNothing);
        expect(find.text('Guardar Rutina'), findsNothing);
      },
    );

    testWidgets(
      'debe mostrar la tarjeta del ejercicio y el botón limpiar si hay items',
      (WidgetTester tester) async {
        // Arrange
        controller.addDay(nombre: 'Día 1');
        controller.addExercise(mockEjercicio);

        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Assert
        expect(
          find.text('Nueva Rutina de entrenamiento'),
          findsOneWidget,
        ); // 👈 cambió
        expect(find.textContaining('1 días'), findsOneWidget); // 👈 cambió
        expect(find.text('Dominadas'), findsOneWidget);
        expect(find.text('Limpiar Todo'), findsOneWidget);
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
      await tester.pumpAndSettle();
      // Confirmar el diálogo de confirmación
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

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
      controller.addDay(nombre: 'Día 1');
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
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

    testWidgets('debe mostrar botón para agregar día', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Agregar día'), findsOneWidget);
    });

    testWidgets('debe mostrar el día creado en el workspace', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      controller.addDay(nombre: 'Día 1 - Pecho');

      debugPrint('Días antes de pump: ${controller.dias.length}');

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // 👈

      // Assert
      expect(find.text('Día 1 - Pecho'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe colapsar y desplegar el día al presionarlo', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      controller.addDay(nombre: 'Día 1');
      controller.addBlock(nombre: 'Bloque 1');
      controller.addExercise(mockEjercicio);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert — desplegado por defecto
      expect(find.text('Bloque 1'), findsOneWidget);

      // Act — colapsar
      await tester.tap(find.text('Día 1'));
      await tester.pumpAndSettle();

      // Assert — colapsado
      expect(find.text('Bloque 1'), findsNothing);

      addTearDown(tester.view.resetPhysicalSize);
    });

    group('Diálogos de confirmación antes de eliminar', () {
      testWidgets(
        'al presionar eliminar ejercicio debe mostrar diálogo de confirmación',
        (WidgetTester tester) async {
          // Arrange
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          final ejercicio2 = Ejercicio(
            idEjercicio: 2,
            nombre: 'Sentadilla',
            categorias: [],
          );
          controller.addDay(nombre: 'Día 1');
          controller.addBlock(nombre: 'Bloque 1');
          controller.addExercise(mockEjercicio);
          controller.addExercise(ejercicio2);

          await tester.pumpWidget(createWidgetUnderTest());

          // Act — presionar ✕ del primer ejercicio
          await tester.tap(find.byIcon(Icons.close).first);
          await tester.pumpAndSettle();

          // Assert — debe aparecer diálogo de confirmación
          expect(find.text('Eliminar ejercicio'), findsOneWidget);
          expect(find.textContaining('¿Estás seguro'), findsOneWidget);
          expect(find.text('Cancelar'), findsOneWidget);
          expect(find.text('Eliminar'), findsOneWidget);

          addTearDown(tester.view.resetPhysicalSize);
        },
      );

      testWidgets(
        'cancelar eliminación de ejercicio debe preservar los datos',
        (WidgetTester tester) async {
          // Arrange
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          final ejercicio2 = Ejercicio(
            idEjercicio: 2,
            nombre: 'Sentadilla',
            categorias: [],
          );
          controller.addDay(nombre: 'Día 1');
          controller.addBlock(nombre: 'Bloque 1');
          controller.addExercise(mockEjercicio);
          controller.addExercise(ejercicio2);

          await tester.pumpWidget(createWidgetUnderTest());

          // Act
          await tester.tap(find.byIcon(Icons.close).first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Cancelar'));
          await tester.pumpAndSettle();

          // Assert — ejercicio sigue presente
          expect(controller.bloques[0].ejercicios.length, 2);
          expect(find.text('Dominadas'), findsOneWidget);

          addTearDown(tester.view.resetPhysicalSize);
        },
      );

      testWidgets(
        'confirmar eliminación de ejercicio debe eliminar el ejercicio',
        (WidgetTester tester) async {
          // Arrange
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          final ejercicio2 = Ejercicio(
            idEjercicio: 2,
            nombre: 'Sentadilla',
            categorias: [],
          );
          controller.addDay(nombre: 'Día 1');
          controller.addBlock(nombre: 'Bloque 1');
          controller.addExercise(mockEjercicio);
          controller.addExercise(ejercicio2);

          await tester.pumpWidget(createWidgetUnderTest());

          // Act
          await tester.tap(find.byIcon(Icons.close).first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Eliminar'));
          await tester.pumpAndSettle();

          // Assert — ejercicio eliminado
          expect(controller.bloques[0].ejercicios.length, 1);
          expect(find.text('Dominadas'), findsNothing);

          addTearDown(tester.view.resetPhysicalSize);
        },
      );

      testWidgets(
        'al presionar eliminar bloque debe mostrar diálogo de confirmación',
        (WidgetTester tester) async {
          // Arrange
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          controller.addDay(nombre: 'Día 1');
          controller.addBlock(nombre: 'Bloque 1');
          controller.addBlock(nombre: 'Bloque 2');
          controller.addExercise(mockEjercicio, blockIndex: 0);

          await tester.pumpWidget(createWidgetUnderTest());

          // Act — delete_outline icons: 0=Limpiar Todo, 1=Día, 2=Bloque1, 3=Bloque2
          final deleteButtons = find.byIcon(Icons.delete_outline);
          await tester.tap(deleteButtons.at(2));
          await tester.pumpAndSettle();

          // Assert
          expect(find.text('Eliminar bloque'), findsOneWidget);
          expect(find.textContaining('¿Estás seguro'), findsOneWidget);

          addTearDown(tester.view.resetPhysicalSize);
        },
      );

      testWidgets('confirmar eliminación de bloque debe eliminar el bloque', (
        WidgetTester tester,
      ) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        controller.addDay(nombre: 'Día 1');
        controller.addBlock(nombre: 'Bloque 1');
        controller.addBlock(nombre: 'Bloque 2');
        controller.addExercise(mockEjercicio, blockIndex: 0);

        await tester.pumpWidget(createWidgetUnderTest());

        // Act — delete_outline icons: 0=Limpiar Todo, 1=Día, 2=Bloque1, 3=Bloque2
        final deleteButtons = find.byIcon(Icons.delete_outline);
        await tester.tap(deleteButtons.at(2));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        // Assert
        expect(controller.bloques.length, 1);
        expect(find.text('Bloque 2'), findsNothing);

        addTearDown(tester.view.resetPhysicalSize);
      });

      testWidgets(
        'al presionar eliminar día debe mostrar diálogo de confirmación',
        (WidgetTester tester) async {
          // Arrange
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          controller.addDay(nombre: 'Día 1');
          controller.addDay(nombre: 'Día 2');

          await tester.pumpWidget(createWidgetUnderTest());

          // Act — delete_outline icons: 0=Limpiar Todo, 1=Día1, 2=Día2
          await tester.tap(find.byIcon(Icons.delete_outline).at(1));
          await tester.pumpAndSettle();

          // Assert
          expect(find.text('Eliminar día'), findsOneWidget);
          expect(find.textContaining('¿Estás seguro'), findsOneWidget);

          addTearDown(tester.view.resetPhysicalSize);
        },
      );

      testWidgets('confirmar eliminación de día debe eliminar el día', (
        WidgetTester tester,
      ) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        controller.addDay(nombre: 'Día 1');
        controller.addDay(nombre: 'Día 2');

        await tester.pumpWidget(createWidgetUnderTest());

        // Act — delete_outline icons: 0=Limpiar Todo, 1=Día1, 2=Día2
        await tester.tap(find.byIcon(Icons.delete_outline).at(1));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        // Assert
        expect(controller.dias.length, 1);

        addTearDown(tester.view.resetPhysicalSize);
      });

      testWidgets(
        'al presionar Limpiar Todo debe mostrar diálogo de confirmación',
        (WidgetTester tester) async {
          // Arrange
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          controller.addDay(nombre: 'Día 1');
          controller.addBlock(nombre: 'Bloque 1');
          controller.addExercise(mockEjercicio);

          await tester.pumpWidget(createWidgetUnderTest());

          // Act
          await tester.tap(find.text('Limpiar Todo'));
          await tester.pumpAndSettle();

          // Assert
          expect(find.text('Limpiar rutina'), findsOneWidget);
          expect(find.textContaining('¿Estás seguro'), findsOneWidget);

          addTearDown(tester.view.resetPhysicalSize);
        },
      );

      testWidgets('cancelar Limpiar Todo debe preservar la rutina', (
        WidgetTester tester,
      ) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        controller.addDay(nombre: 'Día 1');
        controller.addBlock(nombre: 'Bloque 1');
        controller.addExercise(mockEjercicio);

        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.tap(find.text('Limpiar Todo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        // Assert
        expect(controller.dias.length, 1);
        expect(controller.totalEjercicios, 1);

        addTearDown(tester.view.resetPhysicalSize);
      });

      testWidgets('confirmar Limpiar Todo debe vaciar la rutina', (
        WidgetTester tester,
      ) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        controller.addDay(nombre: 'Día 1');
        controller.addBlock(nombre: 'Bloque 1');
        controller.addExercise(mockEjercicio);

        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.tap(find.text('Limpiar Todo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        // Assert
        expect(controller.dias, isEmpty);
        expect(controller.currentRoutine, isEmpty);

        addTearDown(tester.view.resetPhysicalSize);
      });
    });

    group('Edición inline de nombres', () {
      testWidgets(
        'al presionar editar nombre del día debe mostrar TextField editable',
        (WidgetTester tester) async {
          // Arrange — sin ejercicios para evitar TextFields extra
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          controller.addDay(nombre: 'Día 1');

          await tester.pumpWidget(createWidgetUnderTest());

          // Act — tap en el ícono de editar nombre del día
          await tester.tap(find.byIcon(Icons.edit_outlined).first);
          await tester.pumpAndSettle();

          // Assert — debe aparecer el TextField inline (el de notas es el último)
          // Se espera exactamente 2: el inline + el de notas generales
          expect(find.byType(TextField), findsNWidgets(2));
          // El primero (inline) debe tener el texto 'Día 1'
          final inlineField = tester.widget<TextField>(find.byType(TextField).first);
          expect(inlineField.controller?.text, 'Día 1');

          addTearDown(tester.view.resetPhysicalSize);
        },
      );

      testWidgets(
        'al confirmar edición del nombre del día debe actualizar el controller',
        (WidgetTester tester) async {
          // Arrange
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          controller.addDay(nombre: 'Día 1');

          await tester.pumpWidget(createWidgetUnderTest());

          // Act — entrar en modo edición
          await tester.tap(find.byIcon(Icons.edit_outlined).first);
          await tester.pumpAndSettle();

          // Escribir nuevo nombre en el TextField inline (el primero)
          await tester.enterText(find.byType(TextField).first, 'Pecho y Tríceps');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          // Assert
          expect(controller.dias[0].nombre, 'Pecho y Tríceps');
          expect(find.text('Pecho y Tríceps'), findsOneWidget);

          addTearDown(tester.view.resetPhysicalSize);
        },
      );

      testWidgets(
        'al presionar editar nombre del bloque debe mostrar TextField editable',
        (WidgetTester tester) async {
          // Arrange — día con bloque sin ejercicios
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          controller.addDay(nombre: 'Día 1');
          controller.addBlock(nombre: 'Bloque 1');

          await tester.pumpWidget(createWidgetUnderTest());

          // Act — el primer edit_outlined es del día, el segundo del bloque
          final editIcons = find.byIcon(Icons.edit_outlined);
          await tester.tap(editIcons.at(1));
          await tester.pumpAndSettle();

          // Assert — el inline + el de notas = 2 TextFields
          expect(find.byType(TextField), findsNWidgets(2));
          // El primero (inline) debe tener el texto 'Bloque 1'
          final inlineField = tester.widget<TextField>(find.byType(TextField).first);
          expect(inlineField.controller?.text, 'Bloque 1');

          addTearDown(tester.view.resetPhysicalSize);
        },
      );

      testWidgets(
        'al confirmar edición del nombre del bloque debe actualizar el controller',
        (WidgetTester tester) async {
          // Arrange
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          controller.addDay(nombre: 'Día 1');
          controller.addBlock(nombre: 'Bloque 1');

          await tester.pumpWidget(createWidgetUnderTest());

          // Act — tap en el ícono de editar del bloque (segundo edit_outlined)
          final editIcons = find.byIcon(Icons.edit_outlined);
          await tester.tap(editIcons.at(1));
          await tester.pumpAndSettle();

          // Escribir nuevo nombre en el TextField inline (el primero)
          await tester.enterText(find.byType(TextField).first, 'Calentamiento');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          // Assert
          expect(controller.bloques[0].nombre, 'Calentamiento');
          expect(find.text('Calentamiento'), findsOneWidget);

          addTearDown(tester.view.resetPhysicalSize);
        },
      );
    });

    group('Deshacer superserie (uncombine)', () {
      testWidgets(
        'una superserie debe mostrar botón para deshacer la combinación',
        (WidgetTester tester) async {
          // Arrange
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          final ejercicio2 = Ejercicio(
            idEjercicio: 2,
            nombre: 'Remo con Barra',
            categorias: [],
          );
          controller.addDay(nombre: 'Día 1');
          controller.addBlock(nombre: 'Bloque 1');
          controller.addExercise(mockEjercicio);
          controller.confirmCombine(
            blockIndex: 0,
            exerciseIndex: 0,
            ejercicio: ejercicio2,
          );

          await tester.pumpWidget(createWidgetUnderTest());

          // Assert — debe existir un botón para deshacer la superserie
          expect(find.text('SUPERSERIE'), findsOneWidget);
          expect(find.text('Deshacer'), findsOneWidget);

          addTearDown(tester.view.resetPhysicalSize);
        },
      );

      testWidgets(
        'al presionar Deshacer debe quitar el ejercicio combinado y dejar solo el original',
        (WidgetTester tester) async {
          // Arrange
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          final ejercicio2 = Ejercicio(
            idEjercicio: 2,
            nombre: 'Remo con Barra',
            categorias: [],
          );
          controller.addDay(nombre: 'Día 1');
          controller.addBlock(nombre: 'Bloque 1');
          controller.addExercise(mockEjercicio);
          controller.confirmCombine(
            blockIndex: 0,
            exerciseIndex: 0,
            ejercicio: ejercicio2,
          );

          await tester.pumpWidget(createWidgetUnderTest());

          // Pre-assert — es superserie
          expect(controller.bloques[0].ejercicios.length, 1);
          expect(controller.bloques[0].ejercicios[0].esSuperserie, isTrue);

          // Act — presionar Deshacer
          await tester.tap(find.text('Deshacer'));
          await tester.pumpAndSettle();

          // Assert — sigue siendo 1 tarjeta, ya NO es superserie, solo queda el original
          expect(controller.bloques[0].ejercicios.length, 1);
          expect(controller.bloques[0].ejercicios[0].esSuperserie, isFalse);
          expect(
            controller.bloques[0].ejercicios[0].ejercicio.nombre,
            'Dominadas',
          );

          addTearDown(tester.view.resetPhysicalSize);
        },
      );

      testWidgets(
        'al deshacer se deben preservar las series y reps del ejercicio original',
        (WidgetTester tester) async {
          // Arrange
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1.0;
          final ejercicio2 = Ejercicio(
            idEjercicio: 2,
            nombre: 'Remo con Barra',
            categorias: [],
          );
          controller.addDay(nombre: 'Día 1');
          controller.addBlock(nombre: 'Bloque 1');
          controller.addExercise(mockEjercicio);
          // Modificar las series del original antes de combinar
          controller.updateExerciseParams(
            blockIndex: 0,
            exerciseIndex: 0,
            series: 6,
            repeticiones: '8',
          );
          controller.confirmCombine(
            blockIndex: 0,
            exerciseIndex: 0,
            ejercicio: ejercicio2,
            series: 5,
            repeticiones: '12',
          );

          await tester.pumpWidget(createWidgetUnderTest());

          // Act
          await tester.tap(find.text('Deshacer'));
          await tester.pumpAndSettle();

          // Assert — el ejercicio original conserva sus parámetros
          final ej = controller.bloques[0].ejercicios[0];
          expect(ej.series, 6);
          expect(ej.repeticiones, '8');
          expect(ej.esSuperserie, isFalse);

          addTearDown(tester.view.resetPhysicalSize);
        },
      );
    });
    testWidgets('debe mostrar el campo de notas generales', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      controller.addDay(nombre: 'Día 1');

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('notas_generales_field')), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe actualizar las notas al escribir', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      controller.addDay(nombre: 'Día 1');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.byKey(const Key('notas_generales_field')),
        'Descansar 90 segundos entre series',
      );
      await tester.pump();

      // Assert
      expect(find.text('Descansar 90 segundos entre series'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
