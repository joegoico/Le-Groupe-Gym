import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
// Este archivo todavía no existe o no tiene los métodos, ¡por eso va a fallar!
import 'package:le_groupe_gym/presentacion/builder/widgets/routine_builder_controller.dart'; 

void main() {
  group('Routine Builder Controller - Tests de Lógica de Negocio', () {
    late Ejercicio ejercicioMock1;
    late Ejercicio ejercicioMock2;
    late RoutineBuilderController controller;

    setUp(() {
      // Preparamos los datos antes de cada test
      ejercicioMock1 = Ejercicio(
        idEjercicio: 1,
        nombre: 'Press de Banca',
        categorias: [CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular')],
      );
      ejercicioMock2 = Ejercicio(
        idEjercicio: 2,
        nombre: 'Sentadilla',
        categorias: [CategoriaEjercicio(idCategoria: 2, nombre: 'Piernas', tipo: 'grupo_muscular')],
      );
      
      controller = RoutineBuilderController();
    });

    test('Debe iniciar con la lista de la rutina vacía', () {
      expect(controller.currentRoutine, isEmpty);
    });

    test('Debe permitir agregar un ejercicio a la rutina con valores por defecto', () {
      controller.addExercise(ejercicioMock1);

      expect(controller.currentRoutine.length, 1);
      expect(controller.currentRoutine.first.ejercicio.nombre, 'Press de Banca');
      // Valores por defecto esperados
      expect(controller.currentRoutine.first.series, 4);
      expect(controller.currentRoutine.first.repeticiones, '10');
    });

    test('Debe permitir eliminar un ejercicio específico de la rutina', () {
      controller.addExercise(ejercicioMock1);
      controller.addExercise(ejercicioMock2);
      
      // Eliminamos el primero
      controller.removeExercise(0);

      expect(controller.currentRoutine.length, 1);
      expect(controller.currentRoutine.first.ejercicio.nombre, 'Sentadilla');
    });

    test('Debe permitir limpiar toda la rutina de una vez', () {
      controller.addExercise(ejercicioMock1);
      controller.addExercise(ejercicioMock2);
      
      controller.clearRoutine();

      expect(controller.currentRoutine, isEmpty);
    });

    test('Debe permitir actualizar las series y repeticiones de un ejercicio en la rutina', () {
      controller.addExercise(ejercicioMock1);
      
      // Cambiamos a 5 series de 12 repeticiones en el índice 0
      controller.updateExerciseParams(index: 0, series: 5, repeticiones: '12');

      expect(controller.currentRoutine.first.series, 5);
      expect(controller.currentRoutine.first.repeticiones, '12');
    });
  });
}
