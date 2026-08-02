import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/repositories/alumno_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  group('SupabaseAlumnoRepository Null User Tests', () {
    late SupabaseAlumnoRepository repository;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockGoTrueClient;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockGoTrueClient = MockGoTrueClient();
      
      when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
      
      // Simulate no active session
      when(() => mockGoTrueClient.currentUser).thenReturn(null);
      
      repository = SupabaseAlumnoRepository(supabaseClient: mockSupabaseClient);
    });

    test('getAlumnos debe lanzar una excepción descriptiva si currentUser es null', () async {
      expect(
        () => repository.getAlumnos(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('No hay sesión activa.'))),
      );
    });
  });
}
