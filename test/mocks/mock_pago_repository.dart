import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/data/repositories/pago_repository.dart';

class MockPagoRepository implements PagoRepository {
  final List<Pago> _pagos = [];

  @override
  Future<void> insertarPago(Pago pago) async {
    _pagos.add(pago);
  }

  @override
  Future<List<Pago>> getPagosPorAlumnoAno(String idAlumno, int anio) async {
    return _pagos.where((p) => p.idAlumno == idAlumno && p.fechaDePago.year == anio).toList();
  }

  @override
  Future<Pago?> getUltimoPago(String idAlumno) async {
    final alumnoPagos = _pagos.where((p) => p.idAlumno == idAlumno).toList();
    if (alumnoPagos.isEmpty) return null;
    
    alumnoPagos.sort((a, b) => b.fechaDePago.compareTo(a.fechaDePago));
    return alumnoPagos.first;
  }
}
