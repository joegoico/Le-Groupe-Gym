import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/presentacion/forms/exercise_form.dart';
import '../../mocks/mock_exercise_repository.dart';

// ---------------------------------------------------------------------------
// Datos compartidos
// ---------------------------------------------------------------------------
final _categoriasConSubgrupos = [
  CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
  CategoriaEjercicio(idCategoria: 2, nombre: 'Espalda', tipo: 'grupo_muscular'),
  CategoriaEjercicio(
    idCategoria: 10,
    nombre: 'Pectoral Mayor',
    tipo: 'subgrupo',
    idCategoriaPadre: 1,
  ),
  CategoriaEjercicio(
    idCategoria: 11,
    nombre: 'Pectoral Menor',
    tipo: 'subgrupo',
    idCategoriaPadre: 1,
  ),
  CategoriaEjercicio(
    idCategoria: 20,
    nombre: 'Dorsal Ancho',
    tipo: 'subgrupo',
    idCategoriaPadre: 2,
  ),
];

Widget buildForm({
  Function(Map<String, dynamic>)? onGuardar,
  VoidCallback? onCancelar,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: AddExerciseForm(
          categorias: _categoriasConSubgrupos,
          onCancelar: onCancelar ?? () {},
          onGuardar: onGuardar ?? (_) {},
          exerciseRepository: MockExerciseRepository(),
        ),
      ),
    ),
  );
}

void main() {
  group('AddExerciseForm – multi-selección de subgrupos', () {
    testWidgets('1. muestra todos los subgrupos del grupo seleccionado', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildForm());

      // Act: seleccionar grupo "Pecho"
      await tester.tap(find.text('Pecho'));
      await tester.pump();

      // Assert: deben aparecer ambos subgrupos de Pecho
      expect(find.text('Pectoral Mayor'), findsOneWidget);
      expect(find.text('Pectoral Menor'), findsOneWidget);
      // El subgrupo de Espalda no debe aparecer
      expect(find.text('Dorsal Ancho'), findsNothing);
    });

    testWidgets('2. permite seleccionar múltiples subgrupos simultáneamente', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildForm());
      await tester.tap(find.text('Pecho'));
      await tester.pump();

      // Act: seleccionar dos subgrupos
      await tester.tap(find.text('Pectoral Mayor'));
      await tester.pump();
      await tester.tap(find.text('Pectoral Menor'));
      await tester.pump();

      // Assert: ambos chips deben estar visualmente seleccionados.
      // Verificamos que al tocar uno no deselecciona al otro.
      // Usamos key para distinguir el estado seleccionado.
      expect(
        find.byKey(const Key('subgrupo_chip_selected_Pectoral Mayor')),
        findsOneWidget,
        reason: 'Pectoral Mayor debe seguir seleccionado',
      );
      expect(
        find.byKey(const Key('subgrupo_chip_selected_Pectoral Menor')),
        findsOneWidget,
        reason: 'Pectoral Menor debe estar seleccionado al mismo tiempo',
      );
    });

    testWidgets(
      '3. deselecciona un subgrupo individual al volver a tocarlo (toggle)',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildForm());
        await tester.tap(find.text('Pecho'));
        await tester.pump();

        // Seleccionar ambos
        await tester.tap(find.text('Pectoral Mayor'));
        await tester.pump();
        await tester.tap(find.text('Pectoral Menor'));
        await tester.pump();

        // Act: deseleccionar solo "Pectoral Mayor"
        await tester.tap(find.text('Pectoral Mayor'));
        await tester.pump();

        // Assert
        expect(
          find.byKey(const Key('subgrupo_chip_selected_Pectoral Mayor')),
          findsNothing,
          reason: 'Pectoral Mayor debe haberse deseleccionado',
        );
        expect(
          find.byKey(const Key('subgrupo_chip_selected_Pectoral Menor')),
          findsOneWidget,
          reason: 'Pectoral Menor debe seguir seleccionado',
        );
      },
    );

    testWidgets(
      '4. cambiar de grupo limpia todos los subgrupos seleccionados',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildForm());
        await tester.tap(find.text('Pecho'));
        await tester.pump();
        await tester.tap(find.text('Pectoral Mayor'));
        await tester.pump();

        // Act: cambiar a otro grupo
        await tester.tap(find.text('Espalda'));
        await tester.pump();

        // Assert: ya no se muestran los subgrupos de Pecho
        expect(find.text('Pectoral Mayor'), findsNothing);
        expect(find.text('Pectoral Menor'), findsNothing);
        // Aparecen los de Espalda
        expect(find.text('Dorsal Ancho'), findsOneWidget);
        // Ningún chip de subgrupo de Espalda está seleccionado
        expect(
          find.byKey(const Key('subgrupo_chip_selected_Dorsal Ancho')),
          findsNothing,
        );
      },
    );

    testWidgets(
      '5. getCategoriaIds incluye el grupo y TODOS los subgrupos seleccionados',
      (tester) async {
        // Arrange
        List<int>? capturedIds;
        await tester.pumpWidget(
          buildForm(
            onGuardar: (data) =>
                capturedIds = data['categoriaIds'] as List<int>,
          ),
        );

        // Ingresar nombre para habilitar guardar
        await tester.enterText(
          find.byKey(const Key('exercise_name_field')),
          'Press Compuesto',
        );
        await tester.pump();

        // Seleccionar grupo y dos subgrupos
        await tester.tap(find.text('Pecho'));
        await tester.pump();
        await tester.tap(find.text('Pectoral Mayor'));
        await tester.pump();
        await tester.tap(find.text('Pectoral Menor'));
        await tester.pump();

        // Act: guardar
        await tester.tap(find.text('Guardar Ejercicio'));
        await tester.pump();

        // Assert: IDs del grupo (1) + ambos subgrupos (10, 11)
        expect(capturedIds, isNotNull);
        expect(capturedIds, containsAll([1, 10, 11]));
        expect(capturedIds!.length, 3);
      },
    );

    testWidgets(
      '6. getCategoriaIds solo incluye el grupo si no hay subgrupos seleccionados',
      (tester) async {
        // Arrange
        List<int>? capturedIds;
        await tester.pumpWidget(
          buildForm(
            onGuardar: (data) =>
                capturedIds = data['categoriaIds'] as List<int>,
          ),
        );

        await tester.enterText(
          find.byKey(const Key('exercise_name_field')),
          'Press Compuesto',
        );
        await tester.pump();

        // Solo seleccionar el grupo, sin subgrupos
        await tester.tap(find.text('Pecho'));
        await tester.pump();

        // Act: guardar
        await tester.tap(find.text('Guardar Ejercicio'));
        await tester.pump();

        // Assert: solo el ID del grupo
        expect(capturedIds, isNotNull);
        expect(capturedIds, equals([1]));
      },
    );
  });
}
