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
        expect(e.categorias, isNotEmpty,
            reason: 'El ejercicio "${e.nombre}" no tiene categorías');
      }
    });

    test('retorna ejercicio con categorías correctamente mapeadas', () async {
      final result = await repository.getExercises();
      final dominadas = result.firstWhere((e) => e.nombre == 'Dominadas');

      expect(dominadas.categorias.first.nombre, equals('Espalda'));
      expect(dominadas.categorias.first.tipo, equals('grupo_muscular'));
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
      when(() => mockClient.from('Ejercicios')).thenThrow(
        PostgrestException(message: 'relation does not exist'),
      );

      expect(
        () => repository.getExercises(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Error al obtener ejercicios'),
        )),
      );
    });
  });
}