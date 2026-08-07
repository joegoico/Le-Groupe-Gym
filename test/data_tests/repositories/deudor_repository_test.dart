import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/repositories/deudor_repository.dart';
import '../../mocks/mock_deudor_repository.dart';

void main() {
  group('DeudorRepository - contrato', () {
    late DeudorRepository repository;

    setUp(() {
      repository = MockDeudorRepository();
    });

    test('getDeudores debe retornar lista no vacía', () async {
      // Act
      final result = await repository.getDeudores();

      // Assert
      expect(result, isNotEmpty);
    });

    test('getDeudores debe retornar deudores correctamente mapeados', () async {
      // Act
      final result = await repository.getDeudores();

      // Assert
      expect(result.first.nombreCompleto, isNotEmpty);
      expect(result.first.diasAdeudados, greaterThan(0));
    });
  });
}
