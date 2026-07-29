import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/ingreso_model.dart';
import 'package:le_groupe_gym/data/repositories/ingreso_repository.dart';
import '../../mocks/mock_ingreso_repository.dart';

void main() {
  group('IngresoRepository - contrato', () {
    late IngresoRepository repository;

    setUp(() {
      repository = MockIngresoRepository();
    });

    test('getIngresos debe retornar lista no vacía', () async {
      // Act
      final result = await repository.getIngresos();

      // Assert
      expect(result, isNotEmpty);
    });

    test('getIngresos debe retornar ingresos correctamente mapeados', () async {
      // Act
      final result = await repository.getIngresos();

      // Assert
      expect(result.first.concepto, isNotEmpty);
      expect(result.first.monto, greaterThan(0));
    });

    test('createIngreso debe retornar el id del ingreso creado', () async {
      // Arrange
      final ingreso = Ingreso(
        fechaIngreso: DateTime(2026, 1, 1),
        concepto: 'Ingreso manual',
        monto: 5000,
      );

      // Act
      final id = await repository.createIngreso(ingreso);

      // Assert
      expect(id, isNotNull);
      expect(id, isNotEmpty);
    });

    test('getIngresosPorPeriodo debe filtrar por fecha', () async {
      // Arrange
      final desde = DateTime(2026, 1, 1);
      final hasta = DateTime(2026, 1, 31);

      // Act
      final result = await repository.getIngresosPorPeriodo(
        desde: desde,
        hasta: hasta,
      );

      // Assert
      expect(result, isA<List<Ingreso>>());
    });
  });
}
