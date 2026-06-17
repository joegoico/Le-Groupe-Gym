import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';
import 'mocks/mock_exercise_repository.dart';

// Mock del cliente de Supabase con mocktail
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {}

void main() {
  // --- Tests del contrato (via Mock simple) ---
  group('ExerciseRepository - contrato', () {
    late ExerciseRepository repository;

    setUp(() {
      repository = MockExerciseRepository();
    });

    test('retorna lista no vacía', () async {
      final result = await repository.getExercises();
      expect(result, isNotEmpty);
    });

    test('cada ejercicio tiene al menos una categoría', () async {
      final result = await repository.getExercises();
      for (final e in result) {
        expect(
          e.categorias,
          isNotEmpty,
          reason: 'El ejercicio "${e.nombre}" no tiene categorías',
        );
      }
    });

    test('retorna ejercicio con categorías correctamente mapeadas', () async {
      final result = await repository.getExercises();
      final dominadas = result.firstWhere((e) => e.nombre == 'Dominadas');

      expect(dominadas.categorias.first.nombre, equals('Espalda'));
      expect(dominadas.categorias.first.tipo, equals('grupo_muscular'));
    });
    test('createExercise debe retornar el id del ejercicio creado', () async {
      // Arrange
      const nombreEjercicio = 'Press de Banca Inclinado';

      // Act
      final id = await repository.createExercise(
        nombre: nombreEjercicio,
        categoriaIds: [1, 2],
      );

      // Assert
      expect(id, isNotNull);
      expect(id, greaterThan(0));
    });
  });

  // --- Tests de SupabaseExerciseRepository ---
  group('SupabaseExerciseRepository', () {
    late MockSupabaseClient mockClient;
    late SupabaseExerciseRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = SupabaseExerciseRepository(supabaseClient: mockClient);
    });

    test('lanza excepción cuando Supabase tira PostgrestException', () async {
      when(
        () => mockClient.from('Ejercicios'),
      ).thenThrow(PostgrestException(message: 'relation does not exist'));

      expect(
        () => repository.getExercises(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Error al obtener ejercicios'),
          ),
        ),
      );
    });
  });
  group('ExerciseRepository - paginación', () {
    late ExerciseRepository repository;

    setUp(() {
      repository = MockExerciseRepository();
    });

    test(
      'getExercisesPaginated debe retornar máximo 15 ejercicios por página',
      () async {
        // Arrange + Act
        final result = await repository.getExercisesPaginated(
          page: 0,
          limit: 15,
        );

        // Assert
        expect(result.ejercicios.length, lessThanOrEqualTo(15));
      },
    );

    test('getExercisesPaginated debe indicar si hay más páginas', () async {
      // Arrange + Act
      final result = await repository.getExercisesPaginated(page: 0, limit: 15);

      // Assert
      expect(result.hayMas, isA<bool>());
    });

    test(
      'getExercisesPaginated debe respetar filtros de grupo muscular',
      () async {
        // Arrange + Act
        final result = await repository.getExercisesPaginated(
          page: 0,
          limit: 15,
          gruposMusculares: ['Pecho'],
        );

        // Assert — todos los ejercicios retornados deben pertenecer al grupo
        for (final ejercicio in result.ejercicios) {
          expect(
            ejercicio.categorias.any(
              (c) => c.tipo == 'grupo_muscular' && c.nombre == 'Pecho',
            ),
            isTrue,
          );
        }
      },
    );

    test('getExercisesPaginated debe respetar búsqueda por nombre', () async {
      // Arrange + Act
      final result = await repository.getExercisesPaginated(
        page: 0,
        limit: 15,
        searchQuery: 'press',
      );

      // Assert
      for (final ejercicio in result.ejercicios) {
        expect(ejercicio.nombre.toLowerCase(), contains('press'));
      }
    });

    test('página 1 debe retornar ejercicios distintos a página 0', () async {
      // Arrange
      final page0 = await repository.getExercisesPaginated(page: 0, limit: 2);
      final page1 = await repository.getExercisesPaginated(page: 1, limit: 2);

      // Assert
      if (page0.ejercicios.isNotEmpty && page1.ejercicios.isNotEmpty) {
        expect(
          page0.ejercicios.first.idEjercicio,
          isNot(equals(page1.ejercicios.first.idEjercicio)),
        );
      }
    });
  });
}
