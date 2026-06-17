import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';
import 'package:le_groupe_gym/data/models/paginated_exercise_model.dart';

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

  @override
  Future<PaginatedExercises> getExercisesPaginated({
    required int page,
    int limit = 15,
    String? searchQuery,
    List<String>? gruposMusculares,
    List<String>? subgrupos,
  }) async {
    var filtered = List<Ejercicio>.from(_mockData);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (e) => e.nombre.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }
    if (gruposMusculares != null && gruposMusculares.isNotEmpty) {
      filtered = filtered
          .where(
            (e) => e.categorias.any(
              (c) =>
                  c.tipo == 'grupo_muscular' &&
                  gruposMusculares.contains(c.nombre),
            ),
          )
          .toList();
    }

    final offset = page * limit;
    final pageItems = filtered.skip(offset).take(limit + 1).toList();
    final hayMas = pageItems.length > limit;

    return PaginatedExercises(
      ejercicios: hayMas ? pageItems.take(limit).toList() : pageItems,
      hayMas: hayMas,
      page: page,
    );
  }
}
