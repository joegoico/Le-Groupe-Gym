import '../../../data/models/exercise_model.dart';

class SidebarController {
  final List<Ejercicio> allExercises;

  String searchQuery = '';
  final Set<String> selectedMuscleGroups = {};
  final Set<String> selectedSubgroups = {};

  SidebarController({required this.allExercises});

  // ✅ Dinámico — deriva grupos desde los ejercicios
  List<String> get availableMuscleGroups {
    return allExercises
        .expand((e) => e.categorias
            .where((c) => c.tipo == 'grupo_muscular')
            .map((c) => c.nombre))
        .toSet()
        .toList()
      ..sort();
  }

  List<Ejercicio> get filteredExercises {
    return allExercises.where((exercise) {
      final matchesSearch = exercise.nombre
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchesMuscleGroup = selectedMuscleGroups.isEmpty ||
          exercise.categorias.any((c) =>
              c.tipo == 'grupo_muscular' &&
              selectedMuscleGroups.contains(c.nombre));

      final matchesSubgroup = selectedSubgroups.isEmpty ||
          exercise.categorias.any((c) =>
              c.tipo == 'subgrupo' && selectedSubgroups.contains(c.nombre));

      return matchesSearch && matchesMuscleGroup && matchesSubgroup;
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
  }

  void toggleMuscleGroup(String groupName) {
    if (selectedMuscleGroups.contains(groupName)) {
      selectedMuscleGroups.remove(groupName);
      _cleanSubgroupsFor(groupName); // limpia subgrupos huérfanos
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

  // ✅ Dinámico — deriva subgrupos desde los ejercicios del grupo seleccionado
  List<String> getSubgroupsForSelected() {
    if (selectedMuscleGroups.isEmpty) return [];

    return allExercises
        .where((e) => e.categorias.any((c) =>
            c.tipo == 'grupo_muscular' &&
            selectedMuscleGroups.contains(c.nombre)))
        .expand((e) => e.categorias
            .where((c) => c.tipo == 'subgrupo')
            .map((c) => c.nombre))
        .toSet()
        .toList()
      ..sort();
  }

  // ✅ Dinámico — limpia subgrupos del grupo deseleccionado
  void _cleanSubgroupsFor(String groupName) {
    final subgruposDelGrupo = allExercises
        .where((e) => e.categorias.any(
            (c) => c.tipo == 'grupo_muscular' && c.nombre == groupName))
        .expand((e) =>
            e.categorias.where((c) => c.tipo == 'subgrupo').map((c) => c.nombre))
        .toSet();

    selectedSubgroups.removeAll(subgruposDelGrupo);
  }
}