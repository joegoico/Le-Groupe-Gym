import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';

// 1. MOCKS PUROS DE MOCKTAIL
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

// 2. NUESTRO FAKE (Para atajar el await final de la consulta)
class FakePostgrestFilterBuilder extends Fake implements PostgrestFilterBuilder<PostgrestList> {
  final PostgrestList? responseStub;
  final PostgrestException? exceptionStub;

  FakePostgrestFilterBuilder({this.responseStub, this.exceptionStub});

  @override
  Future<R> then<R>(FutureOr<R> Function(PostgrestList value) onValue, {Function? onError}) {
    // Delegamos toda la lógica de asincronía a un Future real de Dart
    final future = exceptionStub != null 
        ? Future<PostgrestList>.error(exceptionStub!)
        : Future<PostgrestList>.value(responseStub!);
    
    return future.then(onValue, onError: onError);
  }
}

void main() {
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late ExerciseRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    repository = ExerciseRepository(supabaseClient: mockClient);
  });

  group('ExerciseRepository Tests', () {
    final PostgrestList jsonMock = [
      {
        'id_ejercicio': 1,
        'nombre': 'Press de Banca',
        'Rel_Ejercicio_Categoria': [
          {
            'Categorias_Ejercicio': {'id_categoria': 1, 'nombre': 'Pecho', 'tipo': 'grupo_muscular'}
          }
        ]
      }
    ];

    test('getExercises debe retornar una lista de Ejercicios cuando Supabase responde con éxito', () async {
      // 1. ARRANGEMENT
      final fakeBuilder = FakePostgrestFilterBuilder(responseStub: jsonMock);
      
      // ¡EL TRUCO ESTABA ACÁ! Usamos thenAnswer para todo porque Supabase es puro Future
      when(() => mockClient.from('Ejercicios')).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select('*, Rel_Ejercicio_Categoria(Categorias_Ejercicio(*))'))
          .thenAnswer((_) => fakeBuilder);

      // 2. ACT
      final resultado = await repository.getExercises();

      // 3. ASSERT
      expect(resultado, isA<List<Ejercicio>>());
      expect(resultado.length, 1);
      expect(resultado.first.nombre, 'Press de Banca');
    });

    test('getExercises debe lanzar una excepción controlada si la base de datos falla', () async {
      // 1. ARRANGEMENT
      final fakeBuilder = FakePostgrestFilterBuilder(
        exceptionStub: PostgrestException(message: 'Error de conexión con Supabase')
      );
      
      when(() => mockClient.from('Ejercicios')).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select('*, Rel_Ejercicio_Categoria(Categorias_Ejercicio(*))'))
          .thenAnswer((_) => fakeBuilder);

      // 2. ACT & 3. ASSERT
      expect(
        () async => await repository.getExercises(),
        throwsA(isA<Exception>()),
      );
    });
  });
}