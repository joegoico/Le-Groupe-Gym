import 'package:le_groupe_gym/data/models/precio_model.dart';
import 'package:le_groupe_gym/data/repositories/precio_repository.dart';

class MockPrecioRepository implements PrecioRepository {
  final List<Precio> _mockData = [
    Precio(idPrecio: 'abc-123', cantidadDias: 2, valor: 10000),
    Precio(idPrecio: 'def-456', cantidadDias: 3, valor: 15000),
    Precio(idPrecio: 'ghi-789', cantidadDias: 5, valor: 18000),
  ];

  @override
  Future<List<Precio>> getPrecios() async => List.from(_mockData);

  @override
  Future<String> createPrecio(Precio precio) async => 'new-uuid-123';

  @override
  Future<void> updatePrecio(Precio precio) async {
    final index = _mockData.indexWhere((p) => p.idPrecio == precio.idPrecio);
    if (index != -1) _mockData[index] = precio;
  }

  @override
  Future<void> deletePrecio(String idPrecio) async {
    _mockData.removeWhere((p) => p.idPrecio == idPrecio);
  }
}
