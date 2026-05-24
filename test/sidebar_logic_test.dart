import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/sidebar_controller.dart';

void main() {
  group('Sidebar Business Logic Tests - Filtros Base', () {
    // Datos semilla ampliados con subgrupos para cubrir todos los escenarios
    final pechito = Ejercicio(
      idEjercicio: 1, 
      nombre: 'Press de Banca Plano', 
      categorias: [
        CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
        CategoriaEjercicio(idCategoria: 10, nombre: 'Pectoral Mayor', tipo: 'subgrupo'),
      ]
    );
    final piernas = Ejercicio(
      idEjercicio: 2, 
      nombre: 'Sentadilla Libre', 
      categorias: [
        CategoriaEjercicio(idCategoria: 2, nombre: 'Piernas', tipo: 'grupo_muscular'),
        CategoriaEjercicio(idCategoria: 11, nombre: 'Cuádriceps', tipo: 'subgrupo'),
      ]
    );
    final crucesPolea = Ejercicio(
      idEjercicio: 3, 
      nombre: 'Cruces de Polea', 
      categorias: [
        CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
        CategoriaEjercicio(idCategoria: 12, nombre: 'Fibras Inferiores', tipo: 'subgrupo'),
      ]
    );
    
    final listaMock = [pechito, piernas, crucesPolea];

    test('Al aplicar un filtro por grupo muscular, la lista filtrada solo debe contener ejercicios de ese grupo', () {
      final controller = SidebarController(allExercises: listaMock);

      controller.toggleMuscleGroup('Pecho');

      expect(controller.filteredExercises.length, 2);
      expect(controller.filteredExercises.any((e) => e.nombre == 'Sentadilla Libre'), isFalse);
      expect(controller.selectedMuscleGroups.contains('Pecho'), true);
    });

    test('Al escribir en el buscador, debe filtrar ignorando mayúsculas y minúsculas', () {
      final controller = SidebarController(allExercises: listaMock);

      controller.setSearchQuery('sEnTaDiLlA');

      expect(controller.filteredExercises.length, 1);
      expect(controller.filteredExercises.first.nombre, 'Sentadilla Libre');
    });

    // ==========================================
    // NUEVOS CASOS: SUBGRUPOS DINÁMICOS
    // ==========================================
    test('getSubgroupsForSelected debe retornar vacío si no hay ningún grupo seleccionado', () {
      final controller = SidebarController(allExercises: listaMock);
      expect(controller.getSubgroupsForSelected(), isEmpty);
    });

    test('getSubgroupsForSelected debe retornar los subgrupos correctos al activar un grupo', () {
      final controller = SidebarController(allExercises: listaMock);
      
      controller.toggleMuscleGroup('Piernas');
      
      final subgrupos = controller.getSubgroupsForSelected();
      expect(subgrupos, contains('Cuádriceps'));
      expect(subgrupos, contains('Isquiotibiales'));
      expect(subgrupos.length, 4); 
    });

    test('Debe filtrar en cascada combinando buscador, grupo y subgrupo', () {
      final controller = SidebarController(allExercises: listaMock);
      
      controller.toggleMuscleGroup('Pecho');
      controller.toggleSubgroup('Pectoral Mayor');
      controller.setSearchQuery('Press');

      final resultado = controller.filteredExercises;
      expect(resultado.length, 1);
      expect(resultado.first.nombre, 'Press de Banca Plano');
    });

    test('Regla de negocio: Al desmarcar un grupo principal se deben limpiar sus subgrupos asociados', () {
      final controller = SidebarController(allExercises: listaMock);
      
      // 1. Activamos padre e hijo
      controller.toggleMuscleGroup('Pecho');
      controller.toggleSubgroup('Pectoral Mayor');
      expect(controller.selectedSubgroups, contains('Pectoral Mayor'));

      // 2. Desactivamos el padre
      controller.toggleMuscleGroup('Pecho');

      // 3. El subgrupo debe haberse borrado automáticamente del estado para no quedar huérfano
      expect(controller.selectedSubgroups, isNot(contains('Pectoral Mayor')));
      expect(controller.selectedSubgroups, isEmpty);
    });
  });
}