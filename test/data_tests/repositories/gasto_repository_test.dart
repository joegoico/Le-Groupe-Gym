import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/gasto_model.dart';
import 'package:le_groupe_gym/data/repositories/gasto_repository.dart';

class MockGastoRepository implements GastoRepository {
  final List<Gasto> _gastos = [];

  @override
  Future<List<Gasto>> getGastosPorPeriodo({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    return _gastos
        .where(
          (g) =>
              g.fecha.isAfter(desde.subtract(const Duration(days: 1))) &&
              g.fecha.isBefore(hasta.add(const Duration(days: 1))),
        )
        .toList();
  }

  @override
  Future<String> createGasto(Gasto gasto) async {
    final newGasto = gasto.copyWith(idGasto: 'fake-id');
    _gastos.add(newGasto);
    return newGasto.idGasto!;
  }

  @override
  Future<void> updateGasto(Gasto gasto) async {
    final index = _gastos.indexWhere((g) => g.idGasto == gasto.idGasto);
    if (index != -1) {
      _gastos[index] = gasto;
    }
  }

  @override
  Future<void> deleteGasto(String idGasto) async {
    _gastos.removeWhere((g) => g.idGasto == idGasto);
  }
}

void main() {
  group('GastoRepository - contrato', () {
    late GastoRepository repository;

    setUp(() {
      repository = MockGastoRepository();
    });

    test('createGasto debe agregar un gasto', () async {
      final gasto = Gasto(
        monto: 1000,
        fecha: DateTime(2026, 1, 1),
        descripcion: 'Compra',
      );
      final id = await repository.createGasto(gasto);
      expect(id, isNotEmpty);

      final gastos = await repository.getGastosPorPeriodo(
        desde: DateTime(2026, 1, 1),
        hasta: DateTime(2026, 1, 31),
      );
      expect(gastos.length, 1);
      expect(gastos.first.monto, 1000);
    });

    test('updateGasto debe actualizar un gasto existente', () async {
      final gasto = Gasto(
        monto: 1000,
        fecha: DateTime(2026, 1, 1),
        descripcion: 'Compra',
      );
      final id = await repository.createGasto(gasto);

      final gastoActualizado = Gasto(
        idGasto: id,
        monto: 2000,
        fecha: DateTime(2026, 1, 1),
        descripcion: 'Compra Actualizada',
      );

      await repository.updateGasto(gastoActualizado);

      final gastos = await repository.getGastosPorPeriodo(
        desde: DateTime(2026, 1, 1),
        hasta: DateTime(2026, 1, 31),
      );
      expect(gastos.length, 1);
      expect(gastos.first.monto, 2000);
      expect(gastos.first.descripcion, 'Compra Actualizada');
    });

    test('deleteGasto debe eliminar un gasto existente', () async {
      final gasto = Gasto(monto: 1000, fecha: DateTime(2026, 1, 1));
      final id = await repository.createGasto(gasto);

      await repository.deleteGasto(id);

      final gastos = await repository.getGastosPorPeriodo(
        desde: DateTime(2026, 1, 1),
        hasta: DateTime(2026, 1, 31),
      );
      expect(gastos, isEmpty);
    });
  });
}
