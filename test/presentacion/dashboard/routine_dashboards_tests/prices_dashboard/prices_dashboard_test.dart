import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';

void main() {
  group('Precio Model Tests', () {
    test('debe instanciar correctamente', () {
      // Arrange + Act
      final precio = Precio(idPrecio: 'abc-123', cantidadDias: 3, valor: 15000);

      // Assert
      expect(precio.idPrecio, 'abc-123');
      expect(precio.cantidadDias, 3);
      expect(precio.valor, 15000);
    });

    test('fromMap debe mapear correctamente desde Supabase', () {
      // Arrange
      final jsonMock = {
        'id_precio': 'abc-123',
        'cantidad_dias': 3,
        'valor': 15000,
      };

      // Act
      final precio = Precio.fromMap(jsonMock);

      // Assert
      expect(precio.idPrecio, 'abc-123');
      expect(precio.cantidadDias, 3);
      expect(precio.valor, 15000);
    });

    test('toMap debe exportar la estructura correcta para Supabase', () {
      // Arrange
      final precio = Precio(idPrecio: 'abc-123', cantidadDias: 3, valor: 15000);

      // Act
      final mapa = precio.toMap();

      // Assert
      expect(mapa['cantidad_dias'], 3);
      expect(mapa['valor'], 15000);
      expect(mapa.containsKey('id_precio'), isFalse);
    });

    test('copyWith debe clonar modificando atributos específicos', () {
      // Arrange
      final original = Precio(
        idPrecio: 'abc-123',
        cantidadDias: 3,
        valor: 15000,
      );

      // Act
      final clon = original.copyWith(valor: 18000);

      // Assert
      expect(clon.idPrecio, 'abc-123');
      expect(clon.cantidadDias, 3);
      expect(clon.valor, 18000);
    });
  });
}
