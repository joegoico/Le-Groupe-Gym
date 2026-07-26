import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/deudor_model.dart';

void main() {
  group('Deudor Model Tests', () {
    test('debe instanciar correctamente', () {
      // Arrange + Act
      final deudor = Deudor(
        idDeudor: 'abc-123',
        nombre: 'Juan',
        apellido: 'Pérez',
        diasAdeudados: 30,
        createdAt: DateTime(2026, 1, 1),
      );

      // Assert
      expect(deudor.idDeudor, 'abc-123');
      expect(deudor.nombre, 'Juan');
      expect(deudor.apellido, 'Pérez');
      expect(deudor.diasAdeudados, 30);
    });

    test('debe tener getter nombreCompleto', () {
      // Arrange
      final deudor = Deudor(
        idDeudor: 'abc-123',
        nombre: 'Juan',
        apellido: 'Pérez',
        diasAdeudados: 30,
        createdAt: DateTime(2026, 1, 1),
      );

      // Assert
      expect(deudor.nombreCompleto, 'Juan Pérez');
    });

    test('fromMap debe mapear correctamente desde Supabase', () {
      // Arrange
      final jsonMock = {
        'id_deudor': 'abc-123',
        'nombre': 'Juan',
        'apellido': 'Pérez',
        'dias_adeudados': 30,
        'created_at': '2026-01-01T00:00:00.000Z',
      };

      // Act
      final deudor = Deudor.fromMap(jsonMock);

      // Assert
      expect(deudor.idDeudor, 'abc-123');
      expect(deudor.nombre, 'Juan');
      expect(deudor.diasAdeudados, 30);
    });

    test('toMap debe exportar la estructura correcta para Supabase', () {
      // Arrange
      final deudor = Deudor(
        idDeudor: 'abc-123',
        nombre: 'Juan',
        apellido: 'Pérez',
        diasAdeudados: 30,
        createdAt: DateTime(2026, 1, 1),
      );

      // Act
      final mapa = deudor.toMap();

      // Assert
      expect(mapa['dias_adeudados'], 30);
      expect(mapa.containsKey('created_at'), isFalse);
    });
  });
}
