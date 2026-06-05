import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/widget_muscular_groups.dart';

void main() {
  group('MuscleCategorySelector Tests', () {
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
        idCategoriaPadre: 1, // 👈 pertenece a Pecho
      ),
      CategoriaEjercicio(
        idCategoria: 4,
        nombre: 'Dorsal Ancho',
        tipo: 'subgrupo',
        idCategoriaPadre: 2, // 👈 pertenece a Espalda
      ),
    ];

    Widget createWidgetUnderTest({
      Set<String> selectedGroups = const {},
      Set<String> selectedSubgroups = const {},
      Function(String)? onToggleGroup,
      Function(String)? onToggleSubgroup,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: MuscleCategorySelector(
            categorias: mockCategorias,
            selectedGroups: selectedGroups,
            selectedSubgroups: selectedSubgroups,
            onToggleGroup: onToggleGroup ?? (_) {},
            onToggleSubgroup: onToggleSubgroup ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('debe mostrar los grupos musculares disponibles', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Pecho'), findsOneWidget);
      expect(find.text('Espalda'), findsOneWidget);
    });

    testWidgets('no debe mostrar subgrupos si no hay grupo seleccionado', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Pectoral Mayor'), findsNothing);
      expect(find.text('Dorsal Ancho'), findsNothing);
    });

    testWidgets('debe mostrar solo los subgrupos del grupo seleccionado', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest(selectedGroups: {'Pecho'}));

      // Assert
      expect(
        find.text('Pectoral Mayor'),
        findsOneWidget,
      ); // ✅ pertenece a Pecho
      expect(find.text('Dorsal Ancho'), findsNothing); // ❌ pertenece a Espalda
    });

    testWidgets('debe llamar onToggleGroup al presionar un grupo', (
      tester,
    ) async {
      // Arrange
      String? toggled;
      await tester.pumpWidget(
        createWidgetUnderTest(onToggleGroup: (grupo) => toggled = grupo),
      );

      // Act
      await tester.tap(find.text('Pecho'));
      await tester.pump();

      // Assert
      expect(toggled, 'Pecho');
    });

    testWidgets('debe llamar onToggleSubgroup al presionar un subgrupo', (
      tester,
    ) async {
      // Arrange
      String? toggled;
      await tester.pumpWidget(
        createWidgetUnderTest(
          selectedGroups: {'Pecho'},
          onToggleSubgroup: (sub) => toggled = sub,
        ),
      );

      // Act
      await tester.tap(find.text('Pectoral Mayor'));
      await tester.pump();

      // Assert
      expect(toggled, 'Pectoral Mayor');
    });
  });
}
