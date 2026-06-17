import '../../data/models/exercise_model.dart';
import '../../data/models/category_exercise_model.dart';

class SidebarController {
  final List<Ejercicio> allExercises;

  // ── Paginación ───────────────────────────────────────────────────
  List<Ejercicio> _loadedExercises = [];
  int _currentPage = 0;
  bool _hayMas = false;
  bool _isLoadingMore = false;

  List<Ejercicio> get loadedExercises => List.from(_loadedExercises);
  int get currentPage => _currentPage;
  bool get hayMas => _hayMas;
  bool get isLoadingMore => _isLoadingMore;

  // ── Filtros ──────────────────────────────────────────────────────
  String searchQuery = '';
  final Set<String> selectedMuscleGroups = {};
  final Set<String> selectedSubgroups = {};

  SidebarController({required this.allExercises}) {
    _loadedExercises = List.from(allExercises);
  }

  // ── Métodos de paginación ────────────────────────────────────────
  void setPage({
    required List<Ejercicio> ejercicios,
    required bool hayMas,
    required int page,
  }) {
    if (page == 0) {
      _loadedExercises = List.from(ejercicios);
    } else {
      _loadedExercises = [..._loadedExercises, ...ejercicios];
    }
    _currentPage = page;
    _hayMas = hayMas;
    _isLoadingMore = false;
  }

  void setLoadingMore(bool loading) {
    _isLoadingMore = loading;
  }

  void resetPagination() {
    _loadedExercises = [];
    _currentPage = 0;
    _hayMas = false;
    _isLoadingMore = false;
  }

  // ── Filtros (igual que antes) ────────────────────────────────────
  List<String> get availableMuscleGroups {
    return allExercises
        .expand(
          (e) => e.categorias
              .where((c) => c.tipo == 'grupo_muscular')
              .map((c) => c.nombre),
        )
        .toSet()
        .toList()
      ..sort();
  }

  List<CategoriaEjercicio> get categoriasDisponibles {
    return allExercises.expand((e) => e.categorias).toSet().toList();
  }

  List<Ejercicio> get filteredExercises {
    return _loadedExercises.where((exercise) {
      final matchesSearch = exercise.nombre.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      final matchesMuscleGroup =
          selectedMuscleGroups.isEmpty ||
          exercise.categorias.any(
            (c) =>
                c.tipo == 'grupo_muscular' &&
                selectedMuscleGroups.contains(c.nombre),
          );

      final matchesSubgroup =
          selectedSubgroups.isEmpty ||
          exercise.categorias.any(
            (c) => c.tipo == 'subgrupo' && selectedSubgroups.contains(c.nombre),
          );

      return matchesSearch && matchesMuscleGroup && matchesSubgroup;
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
  }

  void toggleMuscleGroup(String groupName) {
    if (selectedMuscleGroups.contains(groupName)) {
      selectedMuscleGroups.remove(groupName);
      _cleanSubgroupsFor(groupName);
    } else {
      selectedMuscleGroups.add(groupName);
    }
  }

  void toggleSubgroup(String subgroupName) {
    if (selectedSubgroups.contains(subgroupName)) {
      selectedSubgroups.remove(subgroupName);
    } else {
      selectedSubgroups.add(subgroupName);
    }
  }

  List<String> getSubgroupsForSelected() {
    if (selectedMuscleGroups.isEmpty) return [];
    return allExercises
        .where(
          (e) => e.categorias.any(
            (c) =>
                c.tipo == 'grupo_muscular' &&
                selectedMuscleGroups.contains(c.nombre),
          ),
        )
        .expand(
          (e) => e.categorias
              .where((c) => c.tipo == 'subgrupo')
              .map((c) => c.nombre),
        )
        .toSet()
        .toList()
      ..sort();
  }

  void _cleanSubgroupsFor(String groupName) {
    final subgruposDelGrupo = allExercises
        .where(
          (e) => e.categorias.any(
            (c) => c.tipo == 'grupo_muscular' && c.nombre == groupName,
          ),
        )
        .expand(
          (e) => e.categorias
              .where((c) => c.tipo == 'subgrupo')
              .map((c) => c.nombre),
        )
        .toSet();
    selectedSubgroups.removeAll(subgruposDelGrupo);
  }
}
