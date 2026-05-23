import '../../../data/models/exercise_model.dart';

class SidebarController {
  final List<Ejercicio> allExercises;
  
  String searchQuery = '';
  final Set<String> selectedMuscleGroups = {};
  final Set<String> selectedSubgroups = {}; // <-- Nuevo estado para los subgrupos

  SidebarController({required this.allExercises});

  // Retorna la lista filtrada calculada en tiempo real combinando todo
  List<Ejercicio> get filteredExercises {
    return allExercises.where((exercise) {
      // 1. Filtro por buscador
      final matchesSearch = exercise.nombre.toLowerCase().contains(searchQuery.toLowerCase());

      // 2. Filtro por grupo muscular principal
      final matchesMuscleGroup = selectedMuscleGroups.isEmpty || 
          exercise.categorias.any((c) => c.tipo == 'grupo_muscular' && selectedMuscleGroups.contains(c.nombre));

      // 3. Filtro por subgrupo (Músculo secundario / específico)
      final matchesSubgroup = selectedSubgroups.isEmpty || 
          exercise.categorias.any((c) => c.tipo == 'subgrupo' && selectedSubgroups.contains(c.nombre));

      return matchesSearch && matchesMuscleGroup && matchesSubgroup;
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
  }

  void toggleMuscleGroup(String groupName) {
    if (selectedMuscleGroups.contains(groupName)) {
      selectedMuscleGroups.remove(groupName);
      // REGLA DE NEGOCIO: Si deseleccionás el grupo padre, limpiamos sus subgrupos asociados
      _cleanSubgroupsFor(groupName);
    } else {
      selectedMuscleGroups.add(groupName);
    }
  }

  // Nuevo método para activar/desactivar subgrupos
  void toggleSubgroup(String subgroupName) {
    if (selectedSubgroups.contains(subgroupName)) {
      selectedSubgroups.remove(subgroupName);
    } else {
      selectedSubgroups.add(subgroupName);
    }
  }

  // Mapeo rústico pero efectivo en memoria de qué subgrupos pertenecen a qué grupo principal
  List<String> getSubgroupsForSelected() {
    final List<String> availableSubgroups = [];
    
    // Mapeamos las relaciones de Le Groupe Gym
    if (selectedMuscleGroups.contains('Pecho')) {
      availableSubgroups.addAll(['Fibras Superiores', 'Fibras Inferiores', 'Pectoral Mayor']);
    }
    if (selectedMuscleGroups.contains('Piernas')) {
      availableSubgroups.addAll(['Cuádriceps', 'Isquiotibiales', 'Glúteos', 'Pantorrillas']);
    }
    if (selectedMuscleGroups.contains('Espalda')) {
      availableSubgroups.addAll(['Dorsal Ancho', 'Trapecio', 'Lumbar']);
    }
    if (selectedMuscleGroups.contains('Hombros')) {
      availableSubgroups.addAll(['Deltoides Anterior', 'Deltoides Lateral', 'Deltoides Posterior']);
    }

    return availableSubgroups.toSet().toList(); // Evitamos duplicados
  }

  void _cleanSubgroupsFor(String groupName) {
    if (groupName == 'Pecho') selectedSubgroups.removeAll(['Fibras Superiores', 'Fibras Inferiores', 'Pectoral Mayor']);
    if (groupName == 'Piernas') selectedSubgroups.removeAll(['Cuádriceps', 'Isquiotibiales', 'Glúteos', 'Pantorrillas']);
    if (groupName == 'Espalda') selectedSubgroups.removeAll(['Dorsal Ancho', 'Trapecio', 'Lumbar']);
    if (groupName == 'Hombros') selectedSubgroups.removeAll(['Deltoides Anterior', 'Deltoides Lateral', 'Deltoides Posterior']);
  }
}