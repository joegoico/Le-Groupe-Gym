import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';

void main() {
  group('Descuento Model Tests', () {
    test('debe instanciar correctamente', () {
      // Arrange + Act
      final descuento = Descuento(id: 'abc-123', valor: 15);

      // Assert
      expect(descuento.id, 'abc-123');
      expect(descuento.valor, 15);
    });

    test('fromMap debe mapear correctamente desde Supabase', () {
      // Arrange
      final jsonMock = {'id': 'abc-123', 'Valor': 15};

      // Act
      final descuento = Descuento.fromMap(jsonMock);

      // Assert
      expect(descuento.id, 'abc-123');
      expect(descuento.valor, 15);
    });

    test('toMap debe exportar la estructura correcta para Supabase', () {
      // Arrange
      final descuento = Descuento(id: 'abc-123', valor: 15);

      // Act
      final mapa = descuento.toMap();

      // Assert
      expect(mapa['Valor'], 15);
      expect(mapa.containsKey('id'), isFalse);
    });

    test('copyWith debe clonar modificando atributos específicos', () {
      // Arrange
      final original = Descuento(id: 'abc-123', valor: 15);

      // Act
      final clon = original.copyWith(valor: 20);

      // Assert
      expect(clon.id, 'abc-123');
      expect(clon.valor, 20);
    });
  });
}
