import 'package:flutter/material.dart';
import '../../../data/models/exercise_model.dart';
import 'sidebar_controller.dart';

class ExcerciseSidebar extends StatefulWidget {
  final List<Ejercicio> allExercises; // Le pasamos la lista base realizada desde la BD o mock
  final ValueChanged<Ejercicio> onAddExercise;

  const ExcerciseSidebar({
    super.key,
    required this.allExercises,
    required this.onAddExercise,
  });

  @override
  State<ExcerciseSidebar> createState() => _ExcerciseSidebarState();
}

class _ExcerciseSidebarState extends State<ExcerciseSidebar> {
  late SidebarController _controller;

  @override
  void initState() {
    super.initState();
    // Inicializamos nuestro controlador inyectándole los ejercicios base
    _controller = SidebarController(allExercises: widget.allExercises);
  }

  @override
  Widget build(BuildContext context) {
    // Le pedimos al controlador la lista ya filtrada bajo las pruebas TDD
    final filteredExercises = _controller.filteredExercises;
    
    // CORRECCIÓN AQUÍ: Sumamos ambos para que la UI sepa el total real de filtros activos
    final activeFiltersCount = _controller.selectedMuscleGroups.length + _controller.selectedSubgroups.length;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          right: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
      ),
      child: Column(
        children: [
          // 1. CABECERA
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                // ==========================================
                // FIX: ENVOLVEMOS EN EXPANDED CON ELLIPSIS
                // ==========================================
                const Expanded(
                  child: Text(
                    'Librería de Ejercicios',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // Evita que rompa si el sidebar se achica
                  ),
                ),
              ],
            ),
          ),
          // 2. BUSCADOR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _controller.setSearchQuery(value);
                });
              },
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

          // 3. SECCIÓN DE FILTROS
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
                
                // ==========================================
                // BLOQUE 1: GRUPOS PRINCIPALES (¡Recuperado!)
                // ==========================================
                const Text('Grupos Principales', style: TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: ['Pecho', 'Espalda', 'Piernas', 'Hombros', 'Biceps', 'Triceps', 'Core / Abdomen'].map((grupo) {
                    final isSelected = _controller.selectedMuscleGroups.contains(grupo);
                    return FilterChip(
                      label: Text(grupo, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.grey)),
                      selected: isSelected,
                      selectedColor: Colors.blueAccent,
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.grey[850],
                      onSelected: (bool selected) {
                        setState(() {
                          _controller.toggleMuscleGroup(grupo);
                        });
                      },
                    );
                  }).toList(),
                ),

                // ==========================================
                // BLOQUE 2: SUBGRUPOS DINÁMICOS
                // ==========================================
                if (_controller.getSubgroupsForSelected().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Subgrupos Específicos', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: _controller.getSubgroupsForSelected().map((String nombreSubgrupo) {
                      final isSelected = _controller.selectedSubgroups.contains(nombreSubgrupo);
                      
                      return FilterChip(
                        label: Text(
                          nombreSubgrupo, 
                          style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.grey)
                        ),
                        selected: isSelected,
                        selectedColor: Colors.teal, 
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.grey[850],
                        onSelected: (bool selected) {
                          setState(() {
                            _controller.toggleSubgroup(nombreSubgrupo);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Colors.black26, height: 1),

          // 4. RESULTADOS Y LISTA
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
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                
                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    title: Text(
                      exercise.nombre, 
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                      onPressed: () => widget.onAddExercise(exercise),
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