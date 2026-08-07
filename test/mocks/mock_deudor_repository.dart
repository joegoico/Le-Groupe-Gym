import 'package:le_groupe_gym/data/models/deudor_model.dart';
import 'package:le_groupe_gym/data/repositories/deudor_repository.dart';

class MockDeudorRepository implements DeudorRepository {
  final List<Deudor> _mockData = [
    Deudor(
      idDeudor: 'abc-123',
      nombre: 'Juan',
      apellido: 'Pérez',
      diasAdeudados: 30,
      createdAt: DateTime(2026, 1, 1),
    ),
    Deudor(
      idDeudor: 'def-456',
      nombre: 'María',
      apellido: 'García',
      diasAdeudados: 15,
      createdAt: DateTime(2026, 1, 2),
    ),
  ];

  @override
  Future<List<Deudor>> getDeudores() async => List.from(_mockData);

  Future<void> eliminarDeudor(String idDeudor) async {
    _mockData.removeWhere((d) => d.idDeudor == idDeudor);
  }

  void insertarDeudor(Deudor deudor) {
    _mockData.add(deudor);
  }

  void clearData() => _mockData.clear();
}
