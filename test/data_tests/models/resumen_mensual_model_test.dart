// test/data_tests/models/resumen_mensual_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/ingreso_model.dart';
import 'package:le_groupe_gym/data/models/resumen_mensual_model.dart';

void main() {
  group('ResumenMensual Model Tests', () {
    final mockIngresos = [
      Ingreso(
        idIngreso: '1',
        fechaIngreso: DateTime(2026, 6, 1),
        concepto: 'Plan de 3 días',
        monto: 15000,
        medioDePago: 'Efectivo',
      ),
      Ingreso(
        idIngreso: '2',
        fechaIngreso: DateTime(2026, 6, 15),
        concepto: 'Plan de 5 días',
        monto: 18000,
        medioDePago: 'Transferencia',
      ),
      Ingreso(
        idIngreso: '3',
        fechaIngreso: DateTime(2026, 6, 20),
        concepto: 'Plan de 2 días',
        monto: 10000,
        medioDePago: 'Efectivo',
      ),
    ];

    test('debe calcular el total correctamente', () {
      // Arrange + Act
      final resumen = ResumenMensual(
        mes: 6,
        anio: 2026,
        ingresos: mockIngresos,
      );

      // Assert
      expect(resumen.total, 43000);
    });

    test('debe calcular el total de efectivo correctamente', () {
      // Arrange + Act
      final resumen = ResumenMensual(
        mes: 6,
        anio: 2026,
        ingresos: mockIngresos,
      );

      // Assert
      expect(resumen.totalEfectivo, 25000);
    });

    test('debe calcular el total de transferencia correctamente', () {
      // Arrange + Act
      final resumen = ResumenMensual(
        mes: 6,
        anio: 2026,
        ingresos: mockIngresos,
      );

      // Assert
      expect(resumen.totalTransferencia, 18000);
    });

    test('debe tener getter de título del mes', () {
      // Arrange + Act
      final resumen = ResumenMensual(
        mes: 6,
        anio: 2026,
        ingresos: mockIngresos,
      );

      // Assert
      expect(resumen.titulo, 'Junio 2026');
    });
  });
}
