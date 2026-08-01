import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/gasto_model.dart';
import 'package:le_groupe_gym/data/models/categoria_gasto_model.dart';

void main() {
  group('Gasto Model Tests', () {
    final mockCategoria = CategoriaGasto(
      idCategoria: 'cat-123',
      nombre: 'Mantenimiento',
    );

    test('debe instanciar correctamente', () {
      // Arrange + Act
      final gasto = Gasto(
        idGasto: 'abc-123',
        monto: 45000,
        fecha: DateTime(2026, 5, 12),
        categoria: mockCategoria,
      );

      // Assert
      expect(gasto.idGasto, 'abc-123');
      expect(gasto.monto, 45000);
      expect(gasto.fecha, DateTime(2026, 5, 12));
    });

    test('fromMap debe mapear correctamente desde Supabase', () {
      // Arrange
      final jsonMock = {
        'id_gasto': 'abc-123',
        'monto': 45000,
        'descripcion': 'Reparación de cintas',
        'fecha': '2026-05-12',
        'id_categoria': 'cat-123',
      };

      // Act
      final gasto = Gasto.fromMap(jsonMock);

      // Assert
      expect(gasto.idGasto, 'abc-123');
      expect(gasto.monto, 45000);
      expect(gasto.descripcion, 'Reparación de cintas');
    });

    test('fromMap debe mapear categoria cuando viene en el join', () {
      // Arrange
      final jsonMock = {
        'id_gasto': 'abc-123',
        'monto': 45000,
        'fecha': '2026-05-12',
        'id_categoria': 'cat-123',
        'Categorias_gastos': {
          'id_categoria': 'cat-123',
          'nombre': 'Mantenimiento',
        },
      };

      // Act
      final gasto = Gasto.fromMap(jsonMock);

      // Assert
      expect(gasto.categoria?.nombre, 'Mantenimiento');
    });

    test('toMap debe exportar la estructura correcta para Supabase', () {
      // Arrange
      final gasto = Gasto(
        idGasto: 'abc-123',
        monto: 45000,
        fecha: DateTime(2026, 5, 12),
        categoria: mockCategoria,
        descripcion: 'Reparación de cintas',
      );

      // Act
      final mapa = gasto.toMap();

      // Assert
      expect(mapa['monto'], 45000);
      expect(mapa['id_categoria'], 'cat-123');
      expect(mapa['fecha'], '2026-05-12');
      expect(mapa.containsKey('id_gasto'), isFalse);
    });

    test('copyWith debe clonar modificando atributos específicos', () {
      // Arrange
      final original = Gasto(
        idGasto: 'abc-123',
        monto: 45000,
        fecha: DateTime(2026, 5, 12),
        categoria: mockCategoria,
      );

      // Act
      final clon = original.copyWith(monto: 50000);

      // Assert
      expect(clon.monto, 50000);
      expect(clon.idGasto, 'abc-123');
    });
  });
}
