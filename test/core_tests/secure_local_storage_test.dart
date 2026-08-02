import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:le_groupe_gym/core/secure_local_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('SecureLocalStorage Tests', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureLocalStorage secureLocalStorage;
    const testKey = 'supabase_auth_token';
    const testToken = 'test_jwt_token_123';

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      secureLocalStorage = SecureLocalStorage(storage: mockStorage);
    });

    test('hasAccessToken debe retornar true si el token existe en el storage', () async {
      when(() => mockStorage.containsKey(key: testKey)).thenAnswer((_) async => true);
      
      final result = await secureLocalStorage.hasAccessToken();
      
      expect(result, isTrue);
      verify(() => mockStorage.containsKey(key: testKey)).called(1);
    });

    test('hasAccessToken debe retornar false si el token no existe', () async {
      when(() => mockStorage.containsKey(key: testKey)).thenAnswer((_) async => false);
      
      final result = await secureLocalStorage.hasAccessToken();
      
      expect(result, isFalse);
      verify(() => mockStorage.containsKey(key: testKey)).called(1);
    });

    test('accessToken debe retornar el token desde el storage', () async {
      when(() => mockStorage.read(key: testKey)).thenAnswer((_) async => testToken);
      
      final result = await secureLocalStorage.accessToken();
      
      expect(result, equals(testToken));
      verify(() => mockStorage.read(key: testKey)).called(1);
    });

    test('removePersistedSession debe borrar el token del storage', () async {
      when(() => mockStorage.delete(key: testKey)).thenAnswer((_) async {});
      
      await secureLocalStorage.removePersistedSession();
      
      verify(() => mockStorage.delete(key: testKey)).called(1);
    });

    test('persistSession debe escribir el token en el storage', () async {
      when(() => mockStorage.write(key: testKey, value: testToken)).thenAnswer((_) async {});
      
      await secureLocalStorage.persistSession(testToken);
      
      verify(() => mockStorage.write(key: testKey, value: testToken)).called(1);
    });
  });
}
