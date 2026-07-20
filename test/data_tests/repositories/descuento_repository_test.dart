import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';
import 'package:le_groupe_gym/data/repositories/descuento_repository.dart';
import '../../mocks/mock_descuento_repository.dart';

void main() {
  group('DescuentoRepository - contrato', () {
    late DescuentoRepository repository;

    setUp(() {
      repository = MockDescuentoRepository();
    });

    test('getDescuentos debe retornar lista no vacía', () async {
      // Act
      final result = await repository.getDescuentos();

      // Assert
      expect(result, isNotEmpty);
    });

    test('createDescuento debe retornar el id del descuento creado', () async {
      // Arrange
      final descuento = Descuento(valor: 15);

      // Act
      final id = await repository.createDescuento(descuento);

      // Assert
      expect(id, isNotNull);
      expect(id, isNotEmpty);
    });

    test('updateDescuento debe completarse sin errores', () async {
      // Arrange
      final descuento = Descuento(id: 'abc-123', valor: 20);

      // Act + Assert
      expect(
        () async => await repository.updateDescuento(descuento),
        returnsNormally,
      );
    });

    test('deleteDescuento debe completarse sin errores', () async {
      // Act + Assert
      expect(
        () async => await repository.deleteDescuento('abc-123'),
        returnsNormally,
      );
    });
  });
}
