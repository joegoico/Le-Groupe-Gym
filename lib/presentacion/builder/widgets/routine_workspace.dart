
import 'package:flutter/material.dart';
import 'routine_builder_controller.dart';

class RoutineWorkspace extends StatelessWidget {
  final RoutineBuilderController controller;
  final VoidCallback onRefresh;
  final VoidCallback onSave; // Callback para guardar la rutina

  const RoutineWorkspace({
    super.key,
    required this.controller,
    required this.onRefresh,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final rutinaActual = controller.currentRoutine;

    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(24.0),
      child: rutinaActual.isEmpty
          ? _buildEmptyState()
          : _buildRoutineWorkspace(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_customize_outlined, color: Colors.grey, size: 48),
          SizedBox(height: 16),
          Text(
            'Zona de Armado de Rutinas',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6),
          Text(
            'Presioná el botón "+" en la librería de ejercicios para empezar',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineWorkspace() {
    final rutinaActual = controller.currentRoutine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================
        // CABECERA CORREGIDA CON 'EXPANDED'
        // ==========================================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // El Expanded evita el overflow empujando el texto sin pisar al botón
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nueva Rutina de Entrenamiento',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Agrega "..." si la pantalla es muy chica
                  ),
                  Text(
                    '${rutinaActual.length} ejercicios seleccionados',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // ==========================================
            // NUEVO: BOTÓN GUARDAR
            // ==========================================
            ElevatedButton.icon(
              // Solo se habilita si hay ejercicios en la rutina
              onPressed: rutinaActual.isEmpty ? null : onSave,
              icon: const Icon(Icons.save, size: 16),
              label: const Text('Guardar Rutina'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 8), // Margen de seguridad entre el texto y el botón
            ElevatedButton.icon(
              onPressed: () {
                controller.clearRoutine();
                onRefresh(); 
              },
              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
              label: const Text('Limpiar Todo', style: TextStyle(color: Colors.redAccent)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                shadowColor: Colors.transparent,
                side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ==========================================
        // LISTA DE TARJETAS
        // ==========================================
        Expanded(
          child: ListView.builder(
            itemCount: rutinaActual.length,
            itemBuilder: (context, index) {
              final item = rutinaActual[index];

              return Card(
                color: const Color(0xFF161616),
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[850]!, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // INFO DEL EJERCICIO (Ya tenía su Expanded, por eso este no falló)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.ejercicio.nombre,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.ejercicio.categorias.isNotEmpty
                                  ? item.ejercicio.categorias.first.nombre
                                  : 'General',
                              style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      // INPUT SERIES
                      _buildMiniInputField(
                        label: 'Series',
                        value: item.series.toString(),
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null) {
                            controller.updateExerciseParams(index: index, series: parsed);
                            onRefresh();
                          }
                        },
                      ),
                      const SizedBox(width: 12),

                      // INPUT REPETICIONES
                      _buildMiniInputField(
                        label: 'Reps',
                        value: item.repeticiones,
                        onChanged: (val) {
                          controller.updateExerciseParams(index: index, repeticiones: val);
                          onRefresh();
                        },
                      ),

                      // BOTÓN REMOVER
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                        onPressed: () {
                          controller.removeExercise(index);
                          onRefresh();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMiniInputField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          height: 32,
          child: TextFormField(
            initialValue: value,
            onChanged: onChanged,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF222222),
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[800]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
