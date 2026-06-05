import 'package:le_groupe_gym/data/repositories/category_exercise_repository.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';

class MockCategoryExerciseRepository implements ICategoryExerciseRepository {
  @override
  Future<List<CategoriaEjercicio>> getCategories() async {
    return [
      CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo'),
      CategoriaEjercicio(
        idCategoria: 2,
        nombre: 'Pectoral Mayor',
        tipo: 'subgrupo',
        idCategoriaPadre: 1,
      ),
      CategoriaEjercicio(idCategoria: 3, nombre: 'Espalda', tipo: 'grupo'),
      CategoriaEjercicio(
        idCategoria: 4,
        nombre: 'Dorsal Ancho',
        tipo: 'subgrupo',
        idCategoriaPadre: 3,
      ),
      CategoriaEjercicio(idCategoria: 5, nombre: 'Pierna', tipo: 'grupo'),
      CategoriaEjercicio(
        idCategoria: 6,
        nombre: 'Cuadriceps',
        tipo: 'subgrupo',
        idCategoriaPadre: 5,
      ),
      CategoriaEjercicio(
        idCategoria: 7,
        nombre: 'Biceps Femoral',
        tipo: 'subgrupo',
        idCategoriaPadre: 5,
      ),
      CategoriaEjercicio(idCategoria: 8, nombre: 'Hombro', tipo: 'grupo'),
      CategoriaEjercicio(
        idCategoria: 9,
        nombre: 'Deltoides Anterior',
        tipo: 'subgrupo',
        idCategoriaPadre: 8,
      ),
      CategoriaEjercicio(
        idCategoria: 10,
        nombre: 'Deltoides Posterior',
        tipo: 'subgrupo',
        idCategoriaPadre: 8,
      ),
      CategoriaEjercicio(
        idCategoria: 11,
        nombre: 'Deltoides Lateral',
        tipo: 'subgrupo',
        idCategoriaPadre: 8,
      ),
    ];
  }
}
