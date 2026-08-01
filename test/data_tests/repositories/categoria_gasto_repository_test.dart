import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/categoria_gasto_model.dart';
import 'package:le_groupe_gym/data/repositories/categoria_gasto_repository.dart';

class MockCategoriaGastoRepository implements CategoriaGastoRepository {
  final List<CategoriaGasto> _categorias = [
    CategoriaGasto(idCategoria: '1', nombre: 'Alquiler'),
  ];

  @override
  Future<List<CategoriaGasto>> getCategoriasGastos() async {
    return _categorias;
  }
}

void main() {
  group('CategoriaGastoRepository - contrato', () {
    late CategoriaGastoRepository repository;

    setUp(() {
      repository = MockCategoriaGastoRepository();
    });

    test('getCategoriasGastos debe retornar lista', () async {
      final result = await repository.getCategoriasGastos();
      expect(result, isNotEmpty);
      expect(result.first.nombre, 'Alquiler');
    });
  });
}
