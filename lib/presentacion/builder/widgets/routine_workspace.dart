import 'package:flutter/material.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';
import 'routine_builder_controller.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

class RoutineWorkspace extends StatelessWidget {
  final RoutineBuilderController controller;
  final void Function(String message)? onShowMessage;

  const RoutineWorkspace({
    super.key,
    required this.controller,
    this.onShowMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          color: const Color(0xFF111111),
          padding: const EdgeInsets.all(24.0),
          child: controller.bloques.isEmpty
              ? _buildEmptyState()
              : _buildRoutineWorkspace(),
        );
      },
    );
  }

  // En _buildEmptyState():
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            color: AppColors.onSurfaceVariant.withOpacity(0.3),
            size: 56,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Zona de Armado de Rutinas', style: AppTextStyles.headlineLg),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Creá un bloque y agregá ejercicios desde la librería',
            style: AppTextStyles.titleMd,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => controller.addBlock(),
            icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
            label: Text('Agregar bloque', style: AppTextStyles.labelCaps),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(AppRadius.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineWorkspace() {
    final bloques = controller.bloques;
    final total = controller.totalEjercicios;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nueva Rutina de Entrenamiento',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${bloques.length} bloques · $total ejercicios',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                controller.addBlock();
              },
              icon: const Icon(Icons.view_agenda_outlined, size: 16),
              label: const Text('Bloque'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                controller.clearRoutine();
              },
              icon: const Icon(
                Icons.delete_outline,
                size: 16,
                color: Colors.redAccent,
              ),
              label: const Text(
                'Limpiar Todo',
                style: TextStyle(color: Colors.redAccent),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                shadowColor: Colors.transparent,
                side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: bloques.length,
            itemBuilder: (context, blockIndex) {
              return _RoutineBlockSection(
                key: ValueKey('block_${bloques[blockIndex].id}'),
                blockIndex: blockIndex,
                bloque: bloques[blockIndex],
                controller: controller,
                onShowMessage: onShowMessage,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RoutineBlockSection extends StatelessWidget {
  final int blockIndex;
  final BloqueRutina bloque;
  final RoutineBuilderController controller;
  final void Function(String message)? onShowMessage;

  const _RoutineBlockSection({
    super.key,
    required this.blockIndex,
    required this.bloque,
    required this.controller,
    this.onShowMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = controller.activeBlockIndex == blockIndex;
    final canDeleteBlock = controller.bloques.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? Colors.blueAccent.withOpacity(0.6)
              : Colors.grey[850]!,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    controller.selectBlock(blockIndex);
                  },
                  child: Row(
                    children: [
                      Icon(
                        isActive
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isActive ? Colors.blueAccent : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bloque.nombre,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isActive)
                        Text(
                          'activo',
                          style: TextStyle(
                            color: Colors.blueAccent.withOpacity(0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (canDeleteBlock)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.grey,
                    size: 20,
                  ),
                  tooltip: 'Eliminar bloque vacío',
                  onPressed: () {
                    final ok = controller.removeBlock(blockIndex);
                    if (!ok) {
                      onShowMessage?.call('No se pudo eliminar el bloque.');
                    }
                  },
                ),
            ],
          ),
          if (bloque.estaVacio)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                isActive
                    ? 'Bloque activo — agregá ejercicios con + en la librería'
                    : 'Sin ejercicios — seleccioná el bloque para agregar',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                controller.reorderExerciseInBlock(
                  blockIndex,
                  oldIndex,
                  newIndex,
                );
              },
              itemCount: bloque.ejercicios.length,
              itemBuilder: (context, exerciseIndex) {
                return _RoutineExerciseCard(
                  key: ValueKey('card_${blockIndex}_$exerciseIndex'),
                  blockIndex: blockIndex,
                  exerciseIndex: exerciseIndex,
                  item: bloque.ejercicios[exerciseIndex],
                  controller: controller,
                  onShowMessage: onShowMessage,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _RoutineExerciseCard extends StatelessWidget {
  final int blockIndex;
  final int exerciseIndex;
  final EjercicioRutina item;
  final RoutineBuilderController controller;
  final void Function(String message)? onShowMessage;

  const _RoutineExerciseCard({
    super.key,
    required this.blockIndex,
    required this.exerciseIndex,
    required this.item,
    required this.controller,
    this.onShowMessage,
  });

  static final _placeholderEjercicio = Ejercicio(
    idEjercicio: -1,
    nombre: '',
    categorias: [],
  );

  @override
  Widget build(BuildContext context) {
    final isCombining = controller.isCombiningAt(blockIndex, exerciseIndex);
    final slotsToShow = isCombining && !item.esSuperserie
        ? [
            item.miembros[0],
            DetalleEjercicioRutina(
              ejercicio: _placeholderEjercicio,
              series: controller.pendingCombineSeries,
              repeticiones: controller.pendingCombineReps,
            ),
          ]
        : item.miembros;

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: item.esSuperserie
              ? Colors.blueAccent.withOpacity(0.4)
              : isCombining
              ? Colors.blueAccent.withOpacity(0.55)
              : Colors.grey[850]!,
          width: isCombining ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReorderableDragStartListener(
              index: exerciseIndex,
              child: const Padding(
                padding: EdgeInsets.only(top: 4, right: 8),
                child: Icon(
                  Icons.drag_handle_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.esSuperserie)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'SUPERSERIE',
                        style: TextStyle(
                          color: Colors.blueAccent.withOpacity(0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  for (
                    var slotIndex = 0;
                    slotIndex < slotsToShow.length;
                    slotIndex++
                  )
                    _buildSlotRow(
                      slotIndex: slotIndex,
                      detalle: slotsToShow[slotIndex],
                      isPendingSlot:
                          isCombining && !item.esSuperserie && slotIndex == 1,
                    ),
                  if (isCombining && !item.esSuperserie) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 14,
                          color: Colors.blueAccent.withOpacity(0.8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Elegí el ejercicio acoplado con + en la librería',
                            style: TextStyle(
                              color: Colors.blueAccent.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          controller.cancelCombining();
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                  if (!item.esSuperserie && !isCombining)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          controller.startCombining(blockIndex, exerciseIndex);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Combinar',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (controller.bloques.length > 1)
              PopupMenuButton<int>(
                icon: const Icon(
                  Icons.swap_horiz,
                  color: Colors.grey,
                  size: 20,
                ),
                tooltip: 'Mover a otro bloque',
                onSelected: (targetBlock) {
                  final ok = controller.moveExercise(
                    fromBlockIndex: blockIndex,
                    fromExerciseIndex: exerciseIndex,
                    toBlockIndex: targetBlock,
                  );
                  if (!ok) {
                    onShowMessage?.call(
                      'No se pudo mover: cada bloque debe conservar al menos un ejercicio.',
                    );
                  }
                },
                itemBuilder: (context) {
                  return [
                    for (var i = 0; i < controller.bloques.length; i++)
                      if (i != blockIndex)
                        PopupMenuItem(
                          value: i,
                          child: Text(controller.bloques[i].nombre),
                        ),
                  ];
                },
              ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
              onPressed: () {
                final ok = controller.removeExercise(blockIndex, exerciseIndex);
                if (!ok) {
                  onShowMessage?.call(
                    'Cada bloque debe tener al menos un ejercicio.',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotRow({
    required int slotIndex,
    required DetalleEjercicioRutina detalle,
    required bool isPendingSlot,
  }) {
    final esPlaceholder = detalle.ejercicio.nombre.isEmpty;
    final nombreVisible = esPlaceholder
        ? 'Pendiente — elegí en la librería'
        : detalle.ejercicio.nombre;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreVisible,
                  style: TextStyle(
                    color: esPlaceholder ? Colors.grey : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: esPlaceholder
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (!esPlaceholder) ...[
                  const SizedBox(height: 4),
                  Text(
                    detalle.ejercicio.categorias.isNotEmpty
                        ? detalle.ejercicio.categorias.first.nombre
                        : 'General',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildMiniInputField(
            key: Key('slot_series_${blockIndex}_${exerciseIndex}_$slotIndex'),
            label: 'Series',
            value: detalle.series.toString(),
            onChanged: (val) {
              final parsed = int.tryParse(val);
              if (parsed == null) return;
              if (isPendingSlot) {
                controller.updatePendingCombineParams(series: parsed);
              } else {
                controller.updateMemberParams(
                  blockIndex: blockIndex,
                  exerciseIndex: exerciseIndex,
                  slotIndex: slotIndex,
                  series: parsed,
                );
              }
            },
          ),
          const SizedBox(width: 12),
          _buildMiniInputField(
            key: Key('slot_reps_${blockIndex}_${exerciseIndex}_$slotIndex'),
            label: 'Reps',
            value: detalle.repeticiones,
            onChanged: (val) {
              if (isPendingSlot) {
                controller.updatePendingCombineParams(repeticiones: val);
              } else {
                controller.updateMemberParams(
                  blockIndex: blockIndex,
                  exerciseIndex: exerciseIndex,
                  slotIndex: slotIndex,
                  repeticiones: val,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInputField({
    required Key key,
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
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
