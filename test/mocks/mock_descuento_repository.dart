import 'package:le_groupe_gym/data/models/descuento_model.dart';
import 'package:le_groupe_gym/data/repositories/descuento_repository.dart';

class MockDescuentoRepository implements DescuentoRepository {
  final List<Descuento> _mockData = [
    Descuento(id: 'abc-123', valor: 15),
    Descuento(id: 'def-456', valor: 20),
  ];

  @override
  Future<List<Descuento>> getDescuentos() async => List.from(_mockData);

  @override
  Future<String> createDescuento(Descuento descuento) async => 'new-uuid-123';

  @override
  Future<void> updateDescuento(Descuento descuento) async {
    final index = _mockData.indexWhere((d) => d.id == descuento.id);
    if (index != -1) _mockData[index] = descuento;
  }

  @override
  Future<void> deleteDescuento(String id) async {
    _mockData.removeWhere((d) => d.id == id);
  }
}
