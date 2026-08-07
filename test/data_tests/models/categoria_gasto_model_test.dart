import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/categoria_gasto_model.dart';

void main() {
  group('CategoriaGasto Model Tests', () {
    test('debe instanciar correctamente', () {
      // Arrange + Act
      final categoria = CategoriaGasto(
        idCategoria: 'abc-123',
        nombre: 'Mantenimiento',
      );

      // Assert
      expect(categoria.idCategoria, 'abc-123');
      expect(categoria.nombre, 'Mantenimiento');
    });

    test('fromMap debe mapear correctamente desde Supabase', () {
      // Arrange
      final jsonMock = {'id_categoria': 'abc-123', 'nombre': 'Servicios'};

      // Act
      final categoria = CategoriaGasto.fromMap(jsonMock);

      // Assert
      expect(categoria.idCategoria, 'abc-123');
      expect(categoria.nombre, 'Servicios');
    });

    test('toMap debe exportar la estructura correcta para Supabase', () {
      // Arrange
      final categoria = CategoriaGasto(
        idCategoria: 'abc-123',
        nombre: 'Sueldos',
      );

      // Act
      final mapa = categoria.toMap();

      // Assert
      expect(mapa['nombre'], 'Sueldos');
      expect(mapa.containsKey('id_categoria'), isFalse);
    });
  });
}
