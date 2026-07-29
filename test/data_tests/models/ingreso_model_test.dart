import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/ingreso_model.dart';

void main() {
  group('Ingreso Model Tests', () {
    test('debe instanciar correctamente', () {
      // Arrange + Act
      final ingreso = Ingreso(
        idIngreso: 'abc-123',
        fechaIngreso: DateTime(2026, 1, 1),
        concepto: 'Plan de 3 días',
        monto: 15000,
      );

      // Assert
      expect(ingreso.idIngreso, 'abc-123');
      expect(ingreso.concepto, 'Plan de 3 días');
      expect(ingreso.monto, 15000);
    });

    test('fromMap debe mapear correctamente desde Supabase', () {
      // Arrange
      final jsonMock = {
        'id_ingreso': 'abc-123',
        'fecha_ingreso': '2026-01-01',
        'concepto': 'Plan de 3 días',
        'monto': 15000,
      };

      // Act
      final ingreso = Ingreso.fromMap(jsonMock);

      // Assert
      expect(ingreso.idIngreso, 'abc-123');
      expect(ingreso.concepto, 'Plan de 3 días');
      expect(ingreso.monto, 15000);
    });

    test('toMap debe exportar la estructura correcta para Supabase', () {
      // Arrange
      final ingreso = Ingreso(
        idIngreso: 'abc-123',
        fechaIngreso: DateTime(2026, 1, 1),
        concepto: 'Plan de 3 días',
        monto: 15000,
      );

      // Act
      final mapa = ingreso.toMap();

      // Assert
      expect(mapa['concepto'], 'Plan de 3 días');
      expect(mapa['monto'], 15000);
      expect(mapa.containsKey('id_ingreso'), isFalse);
    });
  });
}
