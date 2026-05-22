import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/sidebar_controller.dart'; // La clase que vamos a reventar ahora

void main() {
  group('Sidebar Business Logic Tests', () {
    // Datos semilla para las pruebas
    final pechito = Ejercicio(
      idEjercicio: 1, 
      nombre: 'Press de Banca', 
      categorias: [CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular')]
    );
    final piernas = Ejercicio(
      idEjercicio: 2, 
      nombre: 'Sentadilla', 
      categorias: [CategoriaEjercicio(idCategoria: 2, nombre: 'Piernas', tipo: 'grupo_muscular')]
    );
    final listaMock = [pechito, piernas];

    test('Al aplicar un filtro por grupo muscular, la lista filtrada solo debe contener ejercicios de ese grupo', () {
      // 1. ARRANGEMENT
      final controller = SidebarController(allExercises: listaMock);

      // 2. ACT
      controller.toggleMuscleGroup('Pecho');

      // 3. ASSERT
      expect(controller.filteredExercises.length, 1);
      expect(controller.filteredExercises.first.nombre, 'Press de Banca');
      expect(controller.selectedMuscleGroups.contains('Pecho'), true);
    });

    test('Al escribir en el buscador, debe filtrar ignorando mayúsculas y minúsculas', () {
      // 1. ARRANGEMENT
      final controller = SidebarController(allExercises: listaMock);

      // 2. ACT
      controller.setSearchQuery('sEnTaDiLlA');

      // 3. ASSERT
      expect(controller.filteredExercises.length, 1);
      expect(controller.filteredExercises.first.nombre, 'Sentadilla');
    });
  });
}