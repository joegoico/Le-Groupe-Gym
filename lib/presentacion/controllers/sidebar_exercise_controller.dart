import 'package:flutter/foundation.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/category_exercise_model.dart';

class SidebarController extends ChangeNotifier {
  final List<Ejercicio> allExercises;

  // ── Paginación ───────────────────────────────────────────────────
  List<Ejercicio> _loadedExercises = [];

  List<Ejercicio> get loadedExercises => List.from(_loadedExercises);

  // ── Filtros ──────────────────────────────────────────────────────
  String searchQuery = '';
  String? selectedMuscleGroup;
  String? selectedSubgroup;

  SidebarController({required this.allExercises}) {
    _loadedExercises = List.from(allExercises);
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
          selectedMuscleGroup == null ||
          exercise.categorias.any(
            (c) =>
                c.tipo == 'grupo_muscular' && c.nombre == selectedMuscleGroup,
          );

      final matchesSubgroup =
          selectedSubgroup == null ||
          exercise.categorias.any(
            (c) => c.tipo == 'subgrupo' && c.nombre == selectedSubgroup,
          );

      return matchesSearch && matchesMuscleGroup && matchesSubgroup;
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void toggleMuscleGroup(String groupName) {
    if (selectedMuscleGroup == groupName) {
      // Si aprieta el grupo que YA estaba seleccionado, lo deselecciona
      // y también limpia el subgrupo asociado.
      selectedMuscleGroup = null;
      selectedSubgroup = null;
    } else {
      // Si aprieta un grupo nuevo, pisa la selección anterior y limpia el subgrupo.
      selectedMuscleGroup = groupName;
      selectedSubgroup = null;
    }
    notifyListeners();
  }

  void toggleSubgroup(String subgroupName) {
    if (selectedSubgroup == subgroupName) {
      selectedSubgroup = null;
    } else {
      selectedSubgroup = subgroupName;
    }
    notifyListeners();
  }

  List<String> getSubgroupsForSelected() {
    if (selectedMuscleGroup == null) return [];
    return allExercises
        .where(
          (e) => e.categorias.any(
            (c) =>
                c.tipo == 'grupo_muscular' && c.nombre == selectedMuscleGroup,
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
}
