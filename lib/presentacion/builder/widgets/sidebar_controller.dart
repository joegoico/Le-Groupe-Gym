import 'package:le_groupe_gym/data/models/exercise_model.dart';

class SidebarController {
  final List<Ejercicio> allExercises;
  
  String searchQuery = '';
  final Set<String> selectedMuscleGroups = {};

  SidebarController({required this.allExercises});

  // Retorna la lista filtrada calculada en tiempo real
  List<Ejercicio> get filteredExercises {
    return allExercises.where((exercise) {
      // 1. Filtro por buscador (ignora mayúsculas)
      final matchesSearch = exercise.nombre.toLowerCase().contains(searchQuery.toLowerCase());

      // 2. Filtro por chips de grupo muscular
      final matchesMuscleGroup = selectedMuscleGroups.isEmpty || 
          exercise.categorias.any((c) => c.tipo == 'grupo_muscular' && selectedMuscleGroups.contains(c.nombre));

      return matchesSearch && matchesMuscleGroup;
    }).toList();
  }

  // Actualiza el texto de búsqueda
  void setSearchQuery(String query) {
    searchQuery = query;
  }

  // Agrega o quita un grupo muscular del Set de filtros
  void toggleMuscleGroup(String groupName) {
    if (selectedMuscleGroups.contains(groupName)) {
      selectedMuscleGroups.remove(groupName);
    } else {
      selectedMuscleGroups.add(groupName);
    }
  }
}