import 'package:le_groupe_gym/data/models/ingreso_model.dart';
import 'package:le_groupe_gym/data/models/resumen_mensual_model.dart';
import 'package:le_groupe_gym/data/repositories/ingreso_repository.dart';

class MockIngresoRepository implements IngresoRepository {
  final List<Ingreso> _mockData = [
    Ingreso(
      idIngreso: 'abc-123',
      fechaIngreso: DateTime(2026, 1, 15),
      concepto: 'Plan de 3 días',
      monto: 15000,
      medioDePago: 'Efectivo',
    ),
    Ingreso(
      idIngreso: 'def-456',
      fechaIngreso: DateTime(2026, 1, 20),
      concepto: 'Plan de 5 días',
      monto: 18000,
      medioDePago: 'Transferencia',
    ),
  ];

  @override
  Future<List<Ingreso>> getIngresos() async => List.from(_mockData);

  @override
  Future<List<ResumenMensual>> getResumenesMensuales({
    DateTime? desde,
    DateTime? hasta,
    DateTime? fecha,
  }) async {
    // Agrupa _mockData por mes según los filtros aplicados
    final filtrados = _mockData.where((i) {
      if (fecha != null) {
        final f = i.fechaIngreso.toIso8601String().split('T')[0];
        return f == fecha.toIso8601String().split('T')[0];
      }
      if (desde != null && i.fechaIngreso.isBefore(desde)) return false;
      if (hasta != null && i.fechaIngreso.isAfter(hasta)) return false;
      return true;
    });

    final Map<String, List<Ingreso>> grupos = {};
    for (final i in filtrados) {
      final key = '${i.fechaIngreso.year}-${i.fechaIngreso.month}';
      grupos.putIfAbsent(key, () => []).add(i);
    }

    return grupos.entries.map((e) {
      final items = e.value;
      final ef = items
          .where((i) => i.medioDePago?.toLowerCase() == 'efectivo')
          .fold<num>(0, (s, i) => s + i.monto);
      final tr = items
          .where((i) => i.medioDePago?.toLowerCase() == 'transferencia')
          .fold<num>(0, (s, i) => s + i.monto);
      final parts = e.key.split('-');
      return ResumenMensual(
        mes: int.parse(parts[1]),
        anio: int.parse(parts[0]),
        totalEfectivo: ef,
        totalTransferencia: tr,
        total: ef + tr,
      );
    }).toList();
  }

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
