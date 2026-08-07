import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/services/auth_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockGoTrueClient;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockGoTrueClient = MockGoTrueClient();

      when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);

      authService = AuthService(supabaseClient: mockSupabaseClient);
    });

    test(
      'signOut llama correctamente al método signOut del cliente de Supabase',
      () async {
        // Arrange
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async => {});

        // Act
        await authService.signOut();

        // Assert
        verify(() => mockGoTrueClient.signOut()).called(1);
      },
    );
  });
}
