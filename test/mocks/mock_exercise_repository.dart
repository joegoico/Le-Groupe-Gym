import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';

class MockExerciseRepository implements ExerciseRepository {
  final List<Ejercicio> _mockData = [
    Ejercicio(
      idEjercicio: 1,
      nombre: 'Press de Banca',
      categorias: [
        CategoriaEjercicio(
          idCategoria: 1,
          nombre: 'Pecho',
          tipo: 'grupo_muscular',
        ),
      ],
    ),
    Ejercicio(
      idEjercicio: 2,
      nombre: 'Remo con Barra',
      categorias: [
        CategoriaEjercicio(
          idCategoria: 3,
          nombre: 'Espalda',
          tipo: 'grupo_muscular',
        ),
      ],
    ),
    Ejercicio(
      idEjercicio: 3,
      nombre: 'Sentadilla',
      categorias: [
        CategoriaEjercicio(
          idCategoria: 2,
          nombre: 'Piernas',
          tipo: 'grupo_muscular',
        ),
      ],
    ),
    Ejercicio(
      idEjercicio: 4,
      nombre: 'Dominadas',
      categorias: [
        CategoriaEjercicio(
          idCategoria: 3,
          nombre: 'Espalda',
          tipo: 'grupo_muscular',
        ),
      ],
    ),
    Ejercicio(
      idEjercicio: 5,
      nombre: 'Press Inclinado',
      categorias: [
        CategoriaEjercicio(
          idCategoria: 1,
          nombre: 'Pecho',
          tipo: 'grupo_muscular',
        ),
      ],
    ),
  ];

  @override
  Future<List<Ejercicio>> getExercises() async {
    return _mockData;
  }

  @override
  Future<int> createExercise({
    required String nombre,
    required List<int> categoriaIds,
  }) async {
    return 99;
  }
}
