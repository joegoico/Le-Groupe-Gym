import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';

void main() {
  group('ExerciseRepository Tests - Mock Implementation', () {
    // Declaramos la variable usando el contrato (clase abstracta)
    late ExerciseRepository repository;

    setUp(() {
      // Pero le inyectamos la implementación de prueba
      repository = MockExerciseRepository();
    });

    test('getExercises debe retornar una lista completa de ejercicios simulados', () async {
      // Act
      final exercises = await repository.getExercises();

      // Assert
      expect(exercises, isNotEmpty);
      expect(exercises.length, 12); // Ahora sabemos que nuestro mock devuelve exactamente 12 ejercicios
    });

    test('getExercises debe incluir ejercicios específicos y sus categorías bien mapeadas', () async {
      // Act
      final exercises = await repository.getExercises();

      // Assert: Verificamos que contenga los nuevos ejercicios que agregaste
      final tienePesoMuerto = exercises.any((e) => e.nombre == 'Peso Muerto Rumano');
      final tieneVuelos = exercises.any((e) => e.nombre == 'Vuelos Laterales');

      expect(tienePesoMuerto, isTrue);
      expect(tieneVuelos, isTrue);

      // Verificamos que la estructura relacional (Categorías) esté intacta
      final dominadas = exercises.firstWhere((e) => e.nombre == 'Dominadas');
      expect(dominadas.categorias.isNotEmpty, isTrue);
      expect(dominadas.categorias.first.nombre, 'Espalda');
    });
  });
}