import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';
import 'package:le_groupe_gym/data/repositories/precio_repository.dart';
import '../../mocks/mock_precio_repository.dart';

void main() {
  group('PrecioRepository - contrato', () {
    late PrecioRepository repository;

    setUp(() {
      repository = MockPrecioRepository();
    });

    test('getPrecios debe retornar lista no vacía', () async {
      // Act
      final result = await repository.getPrecios();

      // Assert
      expect(result, isNotEmpty);
    });

    test('getPrecios debe retornar precios correctamente mapeados', () async {
      // Act
      final result = await repository.getPrecios();

      // Assert
      expect(result.first.cantidadDias, isNotNull);
      expect(result.first.valor, isNotNull);
    });

    test('createPrecio debe retornar el id del precio creado', () async {
      // Arrange
      final precio = Precio(cantidadDias: 3, valor: 15000);

      // Act
      final id = await repository.createPrecio(precio);

      // Assert
      expect(id, isNotNull);
      expect(id, isNotEmpty);
    });

    test('updatePrecio debe completarse sin errores', () async {
      // Arrange
      final precio = Precio(idPrecio: 'abc-123', cantidadDias: 3, valor: 18000);

      // Act + Assert
      expect(
        () async => await repository.updatePrecio(precio),
        returnsNormally,
      );
    });

    test('deletePrecio debe completarse sin errores', () async {
      // Act + Assert
      expect(
        () async => await repository.deletePrecio('abc-123'),
        returnsNormally,
      );
    });
  });
}
