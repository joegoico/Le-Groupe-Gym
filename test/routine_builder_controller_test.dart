import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_builder_controller.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('Routine Builder Controller - Tests de Lógica de Negocio', () {
    late Ejercicio ejercicioMock1;
    late Ejercicio ejercicioMock2;
    late Ejercicio ejercicioMock3;
    late RoutineBuilderController controller;

    setUp(() {
      ejercicioMock1 = Ejercicio(
        idEjercicio: 1,
        nombre: 'Press de Banca',
        categorias: [
          CategoriaEjercicio(
            idCategoria: 1,
            nombre: 'Pecho',
            tipo: 'grupo_muscular',
          ),
        ],
      );
      ejercicioMock2 = Ejercicio(
        idEjercicio: 2,
        nombre: 'Sentadilla',
        categorias: [
          CategoriaEjercicio(
            idCategoria: 2,
            nombre: 'Piernas',
            tipo: 'grupo_muscular',
          ),
        ],
      );
      ejercicioMock3 = Ejercicio(
        idEjercicio: 3,
        nombre: 'Dominadas',
        categorias: [],
      );

      controller = RoutineBuilderController();
    });

    test('debe iniciar sin bloques ni ejercicios', () {
      expect(controller.bloques, isEmpty);
      expect(controller.currentRoutine, isEmpty);
    });

    test('addBlock debe crear un bloque y marcarlo como activo', () {
      // Act
      controller.addBlock(nombre: 'Calentamiento');

      // Assert
      expect(controller.bloques.length, 1);
      expect(controller.bloques.first.nombre, 'Calentamiento');
      expect(controller.activeBlockIndex, 0);
    });

    test('addExercise debe agregar al bloque activo', () {
      // Arrange
      controller.addBlock();
      controller.addExercise(ejercicioMock1);

      // Assert
      expect(controller.bloques.first.ejercicios.length, 1);
      expect(
        controller.bloques.first.ejercicios.first.ejercicio.nombre,
        'Press de Banca',
      );
      expect(controller.bloques.first.ejercicios.first.series, 4);
    });

    test('no debe permitir eliminar el único ejercicio de un bloque', () {
      // Arrange
      controller.addBlock();
      controller.addExercise(ejercicioMock1);

      // Act
      final ok = controller.removeExercise(0, 0);

      // Assert
      expect(ok, isFalse);
      expect(controller.bloques.first.ejercicios.length, 1);
    });

    test(
      'debe permitir eliminar un ejercicio si el bloque tiene más de uno',
      () {
        // Arrange
        controller.addBlock();
        controller.addExercise(ejercicioMock1);
        controller.addExercise(ejercicioMock2);

        // Act
        final ok = controller.removeExercise(0, 0);

        // Assert
        expect(ok, isTrue);
        expect(controller.bloques.first.ejercicios.length, 1);
        expect(
          controller.bloques.first.ejercicios.first.ejercicio.nombre,
          'Sentadilla',
        );
      },
    );

    test('moveExercise debe mover entre bloques', () {
      // Arrange
      controller.addBlock(nombre: 'Bloque A');
      controller.addBlock(nombre: 'Bloque B');
      controller.addExercise(ejercicioMock1, blockIndex: 0);
      controller.addExercise(ejercicioMock2, blockIndex: 0);
      controller.addExercise(ejercicioMock3, blockIndex: 1);

      // Act
      final ok = controller.moveExercise(
        fromBlockIndex: 0,
        fromExerciseIndex: 1,
        toBlockIndex: 1,
      );

      // Assert
      expect(ok, isTrue);
      expect(controller.bloques[0].ejercicios.length, 1);
      expect(controller.bloques[1].ejercicios.length, 2);
      expect(
        controller.bloques[1].ejercicios.last.ejercicio.nombre,
        'Sentadilla',
      );
    });

    test('no debe mover el último ejercicio dejando el bloque vacío', () {
      // Arrange
      controller.addBlock();
      controller.addBlock();
      controller.addExercise(ejercicioMock1, blockIndex: 0);
      controller.addExercise(ejercicioMock2, blockIndex: 1);

      // Act
      final ok = controller.moveExercise(
        fromBlockIndex: 0,
        fromExerciseIndex: 0,
        toBlockIndex: 1,
      );

      // Assert
      expect(ok, isFalse);
      expect(controller.bloques[0].ejercicios.length, 1);
    });

    test('removeBlock solo si el bloque está vacío y hay más de un bloque', () {
      // Arrange
      controller.addBlock(nombre: 'A');
      controller.addBlock(nombre: 'B');
      controller.addExercise(ejercicioMock1, blockIndex: 0);

      // Act + Assert
      expect(controller.removeBlock(1), isTrue);
      expect(controller.bloques.length, 1);

      expect(controller.removeBlock(0), isFalse);
    });

    test('clearRoutine debe vaciar bloques', () {
      controller.addBlock();
      controller.addExercise(ejercicioMock1);
      controller.clearRoutine();
      expect(controller.bloques, isEmpty);
    });

    test('reorderExerciseInBlock debe reordenar dentro del bloque', () {
      controller.addBlock();
      controller.addExercise(ejercicioMock1);
      controller.addExercise(ejercicioMock2);

      controller.reorderExerciseInBlock(0, 1, 0);

      expect(
        controller.bloques[0].ejercicios[0].ejercicio.nombre,
        'Sentadilla',
      );
      expect(
        controller.bloques[0].ejercicios[1].ejercicio.nombre,
        'Press de Banca',
      );
    });

    test('confirmCombine debe acoplar en bloque e índice correctos', () {
      controller.addBlock();
      controller.addExercise(ejercicioMock1);

      controller.confirmCombine(
        blockIndex: 0,
        exerciseIndex: 0,
        ejercicio: ejercicioMock2,
        series: 3,
        repeticiones: '15',
      );

      final tarjeta = controller.bloques[0].ejercicios.first;
      expect(tarjeta.esSuperserie, isTrue);
      expect(tarjeta.miembros[1].ejercicio.nombre, 'Sentadilla');
    });

    test('handleExerciseFromSidebar debe acoplar en modo combinar', () {
      controller.addBlock();
      controller.addExercise(ejercicioMock1);
      controller.startCombining(0, 0);

      final ok = controller.handleExerciseFromSidebar(ejercicioMock2);

      expect(ok, isTrue);
      expect(controller.bloques[0].ejercicios.first.esSuperserie, isTrue);
    });

    test('buildRutina debe exportar bloques con ejercicios', () {
      controller.addBlock(nombre: 'Fuerza');
      controller.addExercise(ejercicioMock1);

      final rutina = controller.buildRutina(nombre: 'Test', idAlumno: 'x');

      expect(rutina.bloques.length, 1);
      expect(rutina.bloques.first.nombre, 'Fuerza');
      expect(rutina.ejercicios.length, 1);
    });
    test(
      'el nombre del nuevo bloque debe reflejar la cantidad actual de bloques',
      () {
        // Arrange
        controller.addBlock(); // Bloque 1
        controller.addBlock(); // Bloque 2
        controller.removeBlock(0); // eliminamos el primero (está vacío)

        // Act
        controller.addBlock(); // debería ser Bloque 2, no Bloque 3

        // Assert
        expect(controller.bloques.last.nombre, 'Bloque 2');
      },
    );
    test(
      'no debe permitir agregar dos veces el mismo ejercicio en el mismo bloque',
      () {
        controller.addBlock();

        controller.addExercise(ejercicioMock1, blockIndex: 0);
        controller.addExercise(ejercicioMock1, blockIndex: 0);

        expect(controller.bloques[0].ejercicios.length, 1);
      },
    );
    test(
      'no debe permitir agregar el mismo ejercicio en distintos bloques',
      () {
        // Arrange
        controller.addBlock(nombre: 'Bloque A');
        controller.addBlock(nombre: 'Bloque B');
        // Act
        controller.addExercise(ejercicioMock1, blockIndex: 0);
        controller.addExercise(ejercicioMock1, blockIndex: 1);

        // Assert
        expect(controller.bloques[0].ejercicios.length, 1);
        expect(controller.bloques[1].ejercicios.length, 0);
      },
    );
    test(
      'debe permitir eliminar un bloque con ejercicios si hay más de uno',
      () {
        // Arrange
        controller.addBlock(nombre: 'Bloque A');
        controller.addBlock(nombre: 'Bloque B');
        final ejercicio = Ejercicio(
          idEjercicio: 1,
          nombre: 'Press Banca',
          categorias: [],
        );
        controller.addExercise(ejercicio, blockIndex: 0);

        // Act
        final resultado = controller.removeBlock(0);

        // Assert
        expect(resultado, isTrue);
        expect(controller.bloques.length, 1);
        expect(controller.bloques.first.nombre, 'Bloque B');
      },
    );
  });
}
