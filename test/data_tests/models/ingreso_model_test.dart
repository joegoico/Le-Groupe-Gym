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
    test('fromMap debe mapear medio_de_pago correctamente', () {
      // Arrange
      final jsonMock = {
        'id_ingreso': 'abc-123',
        'fecha_ingreso': '2026-01-01',
        'concepto': 'Plan de 3 días',
        'monto': 15000,
        'medio_de_pago': 'Efectivo',
      };

      // Act
      final ingreso = Ingreso.fromMap(jsonMock);

      // Assert
      expect(ingreso.medioDePago, 'Efectivo');
    });
    test('fromMap debe mapear id_pago correctamente', () {
      // Arrange
      final jsonMock = {
        'id_ingreso': 'abc-123',
        'fecha_ingreso': '2026-01-01',
        'concepto': 'Plan de 3 días',
        'monto': 15000,
        'medio_de_pago': 'Efectivo',
        'id_pago': 'pago-uuid-123',
      };

      // Act
      final ingreso = Ingreso.fromMap(jsonMock);

      // Assert
      expect(ingreso.idPago, 'pago-uuid-123');
    });

    test('id_pago puede ser null', () {
      // Arrange
      final jsonMock = {
        'id_ingreso': 'abc-123',
        'fecha_ingreso': '2026-01-01',
        'concepto': 'Ingreso manual',
        'monto': 5000,
      };

      // Act
      final ingreso = Ingreso.fromMap(jsonMock);

      // Assert
      expect(ingreso.idPago, isNull);
    });

    test('medio_de_pago puede ser null', () {
      // Arrange
      final jsonMock = {
        'id_ingreso': 'abc-123',
        'fecha_ingreso': '2026-01-01',
        'concepto': 'Ingreso manual',
        'monto': 5000,
      };

      // Act
      final ingreso = Ingreso.fromMap(jsonMock);

      // Assert
      expect(ingreso.medioDePago, isNull);
    });

    test('toMap debe exportar la estructura correcta para Supabase', () {
      // Arrange
      final ingreso = Ingreso(
        idIngreso: 'abc-123',
        fechaIngreso: DateTime(2026, 1, 1),
        concepto: 'Plan de 3 días',
        monto: 15000,
        medioDePago: 'Efectivo',
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
