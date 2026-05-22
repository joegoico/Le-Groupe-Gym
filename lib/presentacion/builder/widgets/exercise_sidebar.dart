import 'package:flutter/material.dart';
// Asumo que acá vas a importar tus modelos reales cuando los vincules
// import 'package:tu_app/data/models/exercise_model.dart'; 

class ExcerciseSidebar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChange;
  final Set<String> selectedMuscleGroup;
  final ValueChanged<Set<String>> onMuscleGroupsChange;
  final Set<String> selectedSubgroups;
  final ValueChanged<Set<String>> onSubgroupsChange;
  final Set<String> selectedModalities;
  final ValueChanged<Set<String>> onModalitiesChange;
  final List<String> addedExerciseIds; // Cambié a List<String> para emular el addedExerciseIds de React
  final ValueChanged<String> onAddExercise; // Recibe el ID del ejercicio a agregar
  final List<dynamic> allExercises; // Le pasamos la lista base para filtrar en memoria

  // 1. Constructor limpio y constante
  const ExcerciseSidebar({
    super.key,
    required this.searchQuery,
    required this.onSearchChange,
    required this.selectedMuscleGroup,
    required this.onMuscleGroupsChange,
    required this.selectedSubgroups,
    required this.onSubgroupsChange,
    required this.selectedModalities,
    required this.onModalitiesChange,
    required this.addedExerciseIds,
    required this.onAddExercise,
    required this.allExercises,
  });

  @override
  Widget build(BuildContext context) {
    // 2. Lógica calculada al vuelo por cada "re-render" (re-build)
    final filteredExercises = allExercises.where((exercise) {
      final matchesSearch = exercise.nombre.toLowerCase().contains(searchQuery.toLowerCase());
      
      // Acá chequeamos si el ejercicio pertenece al Set de seleccionados (usando tu modelo relacional)
      final matchesMuscleGroup = selectedMuscleGroup.isEmpty || 
          exercise.categorias.any((c) => c.tipo == 'grupo_muscular' && selectedMuscleGroup.contains(c.nombre));
          
      final matchesSubgroup = selectedSubgroups.isEmpty || 
          exercise.categorias.any((c) => c.tipo == 'subgrupo' && selectedSubgroups.contains(c.nombre));
          
      final matchesModality = selectedModalities.isEmpty || 
          exercise.categorias.any((c) => c.tipo == 'modalidad' && selectedModalities.contains(c.nombre));

      return matchesSearch && matchesMuscleGroup && matchesSubgroup && matchesModality;
    }).toList();

    final activeFiltersCount = selectedMuscleGroup.length + selectedSubgroups.length + selectedModalities.length;

    // 3. Ahora sí, acá abajo pintamos la UI usando los contenedores de Flutter
    return Container(
      width: 320, // w-80 equivale a 320px de ancho fijo
      decoration: BoxDecoration(
        color: Colors.grey[900], // Simulamos el bg-sidebar (Dark mode)
        border: Border(
          right: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
      ),
      child:  Column(
        children: [
          // 1. CABECERA (Icono de Mancuerna + Título)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Librería de Ejercicios',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 2. BUSCADOR (TextField con la Lupa)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: onSearchChange,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar ejercicios...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[850],
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.black26, height: 1),

          // 3. SECCIÓN DE FILTROS (Múltiple Selección usando Chips)
          // Usamos un SingleChildScrollView vertical pequeño para que los filtros no te rompan la pantalla
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.filter_list, size: 14, color: Colors.grey),
                        SizedBox(width: 6),
                        Text('FILTROS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (activeFiltersCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$activeFiltersCount activos',
                          style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Un ejemplo de combo de chips para Grupos Musculares (Podés replicar para Subgrupos)
                const Text('Grupos Principales', style: TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: ['Pecho', 'Espalda', 'Piernas', 'Hombros', 'Biceps', 'Triceps', 'Core / Abdomen'].map((grupo) {
                    final isSelected = selectedMuscleGroup.contains(grupo);
                    return FilterChip(
                      label: Text(grupo, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.grey)),
                      selected: isSelected,
                      selectedColor: Colors.blueAccent,
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.grey[850],
                      onSelected: (bool selected) {
                        final newSet = Set<String>.from(selectedMuscleGroup);
                        if (selected) {
                          newSet.add(grupo);
                        } else {
                          newSet.remove(grupo);
                        }
                        onMuscleGroupsChange(newSet);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.black26, height: 1),

          // 4. RESULTADOS Y LISTA SCROLLEABLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filteredExercises.length} ejercicios encontrados',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
          
          // REGLA DE ORO: Expanded para que el ListView ocupe el resto del Sidebar sin desbordar
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                
                // Por ahora usamos un ListTile nativo de Flutter, mañana lo podemos tunear a una Card fachera
                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    title: Text(exercise.nombre, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                      onPressed: () => onAddExercise(exercise.idEjercicio.toString()),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}