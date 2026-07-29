import 'package:le_groupe_gym/data/models/ingreso_model.dart';
import 'package:le_groupe_gym/data/repositories/ingreso_repository.dart';

class MockIngresoRepository implements IngresoRepository {
  final List<Ingreso> _mockData = [
    Ingreso(
      idIngreso: 'abc-123',
      fechaIngreso: DateTime(2026, 1, 15),
      concepto: 'Plan de 3 días',
      monto: 15000,
    ),
    Ingreso(
      idIngreso: 'def-456',
      fechaIngreso: DateTime(2026, 1, 20),
      concepto: 'Plan de 5 días',
      monto: 18000,
    ),
  ];

  @override
  Future<List<Ingreso>> getIngresos() async => List.from(_mockData);

  @override
  Future<String> createIngreso(Ingreso ingreso) async => 'new-uuid-123';

  @override
  Future<List<Ingreso>> getIngresosPorPeriodo({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    return _mockData
        .where(
          (i) =>
              i.fechaIngreso.isAfter(desde.subtract(const Duration(days: 1))) &&
              i.fechaIngreso.isBefore(hasta.add(const Duration(days: 1))),
        )
        .toList();
  }

  @override
  Future<List<Ingreso>> getIngresosPorFecha({required DateTime fecha}) async {
    final targetDate = fecha.toIso8601String().split('T')[0];
    return _mockData
        .where((i) => i.fechaIngreso.toIso8601String().startsWith(targetDate))
        .toList();
  }
}
