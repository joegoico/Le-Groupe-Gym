import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/exercise_sidebar.dart';

void main() {
  group('ExcerciseSidebar Widget Tests - Patrón AAA Estricto', () {
    late List<Ejercicio> mockExercises;
    late Ejercicio? selectedExercise;
    late bool addCallbackCalled;

    setUp(() {
      mockExercises = [
        Ejercicio(
          idEjercicio: 1,
          nombre: 'Dominadas',
          categorias: [
            CategoriaEjercicio(idCategoria: 1, nombre: 'Espalda', tipo: 'grupo_muscular'),
          ],
        ),
        Ejercicio(
          idEjercicio: 2,
          nombre: 'Plancha Abdominal',
          categorias: [
            CategoriaEjercicio(idCategoria: 2, nombre: 'Core / Abdomen', tipo: 'grupo_muscular'),
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
                child: ExcerciseSidebar(
                  allExercises: mockExercises,
                  onAddExercise: (ejercicio) {
                    addCallbackCalled = true;
                    selectedExercise = ejercicio;
                  },
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    testWidgets('Debe renderizar la lista completa de ejercicios y los chips estáticos', (WidgetTester tester) async {
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
      expect(chipFinder1, findsOneWidget);
      expect(chipFinder2, findsOneWidget);
      
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('Debe tener un campo de búsqueda interactivo con su placeholder en plural', (WidgetTester tester) async {
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
    });

    testWidgets('Debe ejecutar el callback onAddExercise al presionar el ícono + de un ejercicio', (WidgetTester tester) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());
      final plusButton = find.byIcon(Icons.add_circle_outline).first;

      // Act
      await tester.tap(plusButton);
      await tester.pump();

      // Assert
      expect(addCallbackCalled, isTrue);
      expect(selectedExercise, isNotNull);
      expect(selectedExercise!.nombre, 'Dominadas');
      
      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}