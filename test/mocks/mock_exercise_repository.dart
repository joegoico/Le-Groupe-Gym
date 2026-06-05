import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';

class MockExerciseRepository implements ExerciseRepository {
  @override
  Future<List<Ejercicio>> getExercises() async {
    return [
      Ejercicio(
        idEjercicio: 1,
        nombre: 'Press de Banca Plano',
        categorias: [
          CategoriaEjercicio(
            idCategoria: 1,
            nombre: 'Pecho',
            tipo: 'grupo_muscular',
          ),
          CategoriaEjercicio(
            idCategoria: 10,
            nombre: 'Pectoral Mayor',
            tipo: 'subgrupo',
          ),
        ],
      ),
      Ejercicio(
        idEjercicio: 2,
        nombre: 'Dominadas',
        categorias: [
          CategoriaEjercicio(
            idCategoria: 3,
            nombre: 'Espalda',
            tipo: 'grupo_muscular',
          ),
          CategoriaEjercicio(
            idCategoria: 13,
            nombre: 'Dorsal Ancho',
            tipo: 'subgrupo',
          ),
        ],
      ),
    ];
  }

  @override
  Future<int> createExercise({
    required String nombre,
    required List<int> categoriaIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 99; // id mock
  }
}
