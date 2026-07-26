import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/data/repositories/pago_repository.dart';

class MockPagoRepository implements PagoRepository {
  final List<Pago> _pagos = [];

  @override
  Future<void> insertarPago(Pago pago) async {
    _pagos.add(pago);
  }

  @override
  Future<List<Pago>> getPagosPorAlumno(String idAlumno, {int? anio, int? mes}) async {
    return _pagos.where((p) {
      if (p.idAlumno != idAlumno) return false;
      if (anio != null && p.fechaDePago.year != anio) return false;
      if (mes != null && p.fechaDePago.month != mes) return false;
      return true;
    }).toList();
  }

  @override
  Future<Pago?> getUltimoPago(String idAlumno) async {
    final pagosAlumno =
        _pagos.where((p) => p.idAlumno == idAlumno).toList();
    if (pagosAlumno.isEmpty) return null;
    pagosAlumno.sort((a, b) => b.fechaDePago.compareTo(a.fechaDePago));
    return pagosAlumno.first;
  }

  @override
  Future<void> updatePago(Pago pago) async {
    final index = _pagos.indexWhere((p) => p.idPago == pago.idPago);
    if (index != -1) {
      _pagos[index] = pago;
    }
  }

  @override
  Future<void> deletePago(String idPago) async {
    _pagos.removeWhere((p) => p.idPago == idPago);
  }
}
