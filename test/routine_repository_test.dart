import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/repositories/routine_repository.dart';

void main() {
  group('RoutineRepository Tests - Mock Implementation', () {
    late RoutineRepository repository;

    setUp(() {
      repository = MockRoutineRepository();
    });

    test('saveRoutine debe retornar true al simular el guardado exitoso', () async {
      // Arrange
      final rutina = Rutina(nombre: 'Rutina Base para Alumno', ejercicios: []);

      // Act
      final result = await repository.saveRoutine(rutina);

      // Assert
      expect(result, isTrue);
    });
  });
}