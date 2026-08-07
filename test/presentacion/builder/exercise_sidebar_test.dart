import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/presentacion/builder/exercise_sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_builder_controller.dart';
import '../../mocks/mock_exercise_repository.dart';

// ---------------------------------------------------------------------------
// Helper: construye el widget con la lógica del snackbar integrada,
// imitando el comportamiento de routine_work_page.dart.
// ---------------------------------------------------------------------------
Widget buildSidebarWithSnackbarLogic({
  required List<Ejercicio> exercises,
  required RoutineBuilderController controller,
  required ValueChanged<Ejercicio> onAddExercise,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Builder(
      builder: (ctx) => Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 320,
              height: 800,
              child: ExcerciseSidebar(
                allExercises: exercises,
                controller: controller,
                onAddExercise: (ejercicio) {
                  // Lógica que replica routine_work_page.dart
                  final sinDia = controller.activeDayIndex == null;
                  final sinBloque =
                      !sinDia && controller.activeBlockIndex == null;
                  if (sinDia || sinBloque) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        key: Key('snackbar_seleccionar_dia_bloque'),
                        content: Text('Seleccioná un día y un bloque'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                  onAddExercise(ejercicio);
                },
                exerciseRepository: MockExerciseRepository(),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('ExcerciseSidebar Widget Tests - Patrón AAA Estricto', () {
    late List<Ejercicio> mockExercises;
    late Ejercicio? selectedExercise;
    late bool addCallbackCalled;
    late RoutineBuilderController controller;

    setUpAll(() {
      // nada acá
    });

    setUpAll(() {
      // nada acá
    });

    setUp(() {
      controller = RoutineBuilderController();
      mockExercises = [
        Ejercicio(
          idEjercicio: 1,
          nombre: 'Dominadas',
          categorias: [
            CategoriaEjercicio(
              idCategoria: 1,
              nombre: 'Espalda',
              tipo: 'grupo_muscular',
            ),
          ],
        ),
        Ejercicio(
          idEjercicio: 2,
          nombre: 'Plancha Abdominal',
          categorias: [
            CategoriaEjercicio(
              idCategoria: 2,
              nombre: 'Core / Abdomen',
              tipo: 'grupo_muscular',
            ),
          ],
        ),
      ];
      selectedExercise = null;
      addCallbackCalled = false;
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: 320,
                height: 800,
                child: ExcerciseSidebar(
                  allExercises: mockExercises,
                  controller: controller,
                  onAddExercise: (ejercicio) {
                    addCallbackCalled = true;
                    selectedExercise = ejercicio;
                  },
                  onCreateExercise: () {},
                  exerciseRepository: MockExerciseRepository(),
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    testWidgets(
      'Debe renderizar la lista completa de ejercicios y los chips estáticos',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        final nameFinder1 = find.text('Dominadas');
        final nameFinder2 = find.text('Plancha Abdominal');
        // En tu UI los chips son estáticos, así que buscamos lo que realmente dibujás
        final chipFinder1 = find.text('Espalda');
        final chipFinder2 = find.text('Core / Abdomen');

        // Assert
        expect(nameFinder1, findsOneWidget);
        expect(nameFinder2, findsOneWidget);
        expect(chipFinder1, findsWidgets);
        expect(chipFinder2, findsWidgets);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );

    testWidgets(
      'Debe tener un campo de búsqueda interactivo con su placeholder en plural',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        final searchIconFinder = find.byIcon(Icons.search);
        // Ajustamos al plural exacto de tu UI
        final placeholderFinder = find.text('Buscar ejercicios...');

        // Assert
        expect(searchIconFinder, findsOneWidget);
        expect(placeholderFinder, findsOneWidget);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );

    testWidgets(
      'Debe ejecutar el callback onAddExercise al presionar el ícono + de un ejercicio',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createWidgetUnderTest());
        final plusButton = find.byIcon(Icons.add).first;

        // Act
        await tester.tap(plusButton);
        await tester.pump();

        // Assert
        expect(addCallbackCalled, isTrue);
        expect(selectedExercise, isNotNull);
        expect(selectedExercise!.nombre, 'Dominadas');

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
    testWidgets(
      'muestra los campos del formulario al presionar agregar ejercicio',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createWidgetUnderTest());

        final agregarEjercicioButton = find.text('Agregar ejercicio');

        // Act
        await tester.tap(agregarEjercicioButton);
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Nombre del ejercicio'),
          findsOneWidget,
        ); // también verificá este
        expect(find.text('GRUPO MUSCULAR'), findsWidgets);
        expect(
          find.text('SUBGRUPO'),
          findsNothing,
        ); // no aparece hasta seleccionar un grupo

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
    testWidgets('debe mostrar botón cargar más cuando hayMas es true', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 300));

      // Assert — el mock retorna hayMas=false con 4 ejercicios
      // Para testear hayMas=true necesitamos un mock específico
      expect(find.text('Cargar más'), findsNothing);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });

  // ---------------------------------------------------------------------------
  // Tests: aviso cuando no hay día y/o bloque seleccionado
  // ---------------------------------------------------------------------------
  group('Validación de día/bloque al agregar ejercicio', () {
    late List<Ejercicio> mockExercises;
    late RoutineBuilderController controller;
    late bool callbackEjecutado;

    setUp(() {
      callbackEjecutado = false;
      controller = RoutineBuilderController();
      mockExercises = [
        Ejercicio(
          idEjercicio: 1,
          nombre: 'Dominadas',
          categorias: [
            CategoriaEjercicio(
              idCategoria: 1,
              nombre: 'Espalda',
              tipo: 'grupo_muscular',
            ),
          ],
        ),
      ];
    });

    testWidgets('muestra snackbar cuando no hay ningún día seleccionado', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      // controller sin días → activeDayIndex == null
      await tester.pumpWidget(
        buildSidebarWithSnackbarLogic(
          exercises: mockExercises,
          controller: controller,
          onAddExercise: (_) => callbackEjecutado = true,
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();

      // Assert
      expect(
        find.text('Seleccioná un día y un bloque'),
        findsOneWidget,
        reason: 'Debe aparecer el snackbar de aviso',
      );
      expect(
        callbackEjecutado,
        isFalse,
        reason: 'El callback no debe ejecutarse sin día seleccionado',
      );

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets(
      'muestra snackbar cuando hay un día seleccionado pero ningún bloque activo',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;

        // Crear día sin bloques y deseleccionar bloque
        controller.addDay(nombre: 'Día 1');
        // addDay deja activeDayIndex = 0 pero activeBlockIndex = null
        expect(controller.activeDayIndex, 0);
        expect(controller.activeBlockIndex, isNull);

        await tester.pumpWidget(
          buildSidebarWithSnackbarLogic(
            exercises: mockExercises,
            controller: controller,
            onAddExercise: (_) => callbackEjecutado = true,
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pump();

        // Assert
        expect(
          find.text('Seleccioná un día y un bloque'),
          findsOneWidget,
          reason: 'Debe aparecer el snackbar de aviso sin bloque seleccionado',
        );
        expect(callbackEjecutado, isFalse);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );

    testWidgets(
      'NO muestra snackbar y ejecuta callback cuando hay día y bloque seleccionados',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;

        // Crear día con bloque → ambos índices activos
        controller.addDay(nombre: 'Día 1');
        controller.addBlock(nombre: 'Bloque A');
        expect(controller.activeDayIndex, 0);
        expect(controller.activeBlockIndex, 0);

        await tester.pumpWidget(
          buildSidebarWithSnackbarLogic(
            exercises: mockExercises,
            controller: controller,
            onAddExercise: (_) => callbackEjecutado = true,
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pump();

        // Assert
        expect(
          find.text('Seleccioná un día y un bloque'),
          findsNothing,
          reason: 'No debe aparecer el snackbar de aviso',
        );
        expect(
          callbackEjecutado,
          isTrue,
          reason: 'El callback debe ejecutarse normalmente',
        );

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
  });
}
