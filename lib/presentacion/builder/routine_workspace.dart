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
          color: AppColors.surfaceContainerLow,
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

  // En _buildRoutineWorkspace() — cabecera:
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
                  Text(
                    'Nueva Rutina de Entrenamiento',
                    style: AppTextStyles.headlineLg,
                  ),
                  Text(
                    '${bloques.length} bloques · $total ejercicios',
                    style: AppTextStyles.titleMd,
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => controller.addBlock(),
              icon: const Icon(Icons.add, size: 14, color: AppColors.primary),
              label: Text('Bloque', style: AppTextStyles.titleMd),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton.icon(
              onPressed: () => controller.clearRoutine(),
              icon: const Icon(
                Icons.delete_outline,
                size: 14,
                color: AppColors.error,
              ),
              label: Text('Limpiar Todo', style: AppTextStyles.titleMd),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 100),
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

  // _RoutineBlockSection — rediseñado:
  @override
  Widget build(BuildContext context) {
    final isActive = controller.activeBlockIndex == blockIndex;
    final canDeleteBlock = controller.bloques.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withOpacity(0.4)
              : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header del bloque
          InkWell(
            onTap: () => controller.selectBlock(blockIndex),
            borderRadius: const BorderRadius.vertical(top: AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(bloque.nombre, style: AppTextStyles.titleMd),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.all(AppRadius.full),
                      ),
                      child: Text('activo', style: AppTextStyles.labelCaps),
                    ),
                  if (canDeleteBlock)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.onSurfaceVariant.withOpacity(0.5),
                        size: 16,
                      ),
                      onPressed: () {
                        final ok = controller.removeBlock(blockIndex);
                        if (!ok) onShowMessage?.call('No se pudo eliminar.');
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.05)),

          // Contenido del bloque
          if (bloque.estaVacio)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: Text(
                  isActive
                      ? 'Bloque activo — agregá ejercicios con + en la librería'
                      : 'Sin ejercicios — seleccioná el bloque para agregar',
                  style: AppTextStyles.titleMd,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: ReorderableListView.builder(
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

  // _RoutineExerciseCard — rediseñado:
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.all(AppRadius.md),
        border: Border.all(
          color: item.esSuperserie
              ? AppColors.tertiary.withOpacity(0.3)
              : isCombining
              ? AppColors.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ReorderableDragStartListener(
              index: exerciseIndex,
              child: Padding(
                padding: const EdgeInsets.only(top: 2, right: AppSpacing.sm),
                child: Icon(
                  Icons.drag_handle,
                  color: AppColors.onSurfaceVariant.withOpacity(0.3),
                  size: 18,
                ),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: AppSpacing.sm, top: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: const BorderRadius.all(AppRadius.sm),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.esSuperserie)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('SUPERSERIE', style: AppTextStyles.labelCaps),
                    ),
                  for (var i = 0; i < slotsToShow.length; i++)
                    _buildSlotRow(
                      slotIndex: i,
                      detalle: slotsToShow[i],
                      isPendingSlot:
                          isCombining && !item.esSuperserie && i == 1,
                    ),
                  if (isCombining && !item.esSuperserie) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 12,
                          color: AppColors.primary.withOpacity(0.8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Elegí el ejercicio acoplado con + en la librería',
                            style: AppTextStyles.titleMd,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => controller.cancelCombining(),
                        child: Text('Cancelar', style: AppTextStyles.titleMd),
                      ),
                    ),
                  ],
                  if (!item.esSuperserie && !isCombining)
                    OutlinedButton(
                      onPressed: () =>
                          controller.startCombining(blockIndex, exerciseIndex),

                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        backgroundColor: AppColors.surfaceContainerLow,
                        foregroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.surfaceContainerHigh,
                        disabledForegroundColor: AppColors.onSurfaceVariant,
                        elevation: 0,
                        textStyle: AppTextStyles.titleMd,
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(AppRadius.md),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.comfortable,
                      ),
                      child: const Text('Combinar'),
                    ),
                ],
              ),
            ),
            if (controller.bloques.length > 1)
              PopupMenuButton<int>(
                icon: Icon(
                  Icons.swap_horiz,
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                  size: 16,
                ),
                color: AppColors.surfaceContainerHigh,
                onSelected: (targetBlock) {
                  final ok = controller.moveExercise(
                    fromBlockIndex: blockIndex,
                    fromExerciseIndex: exerciseIndex,
                    toBlockIndex: targetBlock,
                  );
                  if (!ok) onShowMessage?.call('No se pudo mover.');
                },
                itemBuilder: (context) => [
                  for (var i = 0; i < controller.bloques.length; i++)
                    if (i != blockIndex)
                      PopupMenuItem(
                        value: i,
                        child: Text(
                          controller.bloques[i].nombre,
                          style: AppTextStyles.titleMd,
                        ),
                      ),
                ],
              ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: AppColors.onSurfaceVariant.withOpacity(0.5),
                size: 16,
              ),
              onPressed: () {
                final ok = controller.removeExercise(blockIndex, exerciseIndex);
                if (!ok) {
                  onShowMessage?.call(
                    'Cada bloque necesita al menos un ejercicio.',
                  );
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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
    final categoria = detalle.ejercicio.categorias.isNotEmpty
        ? detalle.ejercicio.categorias
              .firstWhere(
                (c) => c.tipo == 'grupo_muscular',
                orElse: () => detalle.ejercicio.categorias.first,
              )
              .nombre
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Info del ejercicio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreVisible,
                  style: AppTextStyles.titleMd,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!esPlaceholder && categoria.isNotEmpty)
                  Text(categoria, style: AppTextStyles.subtittles),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Series
          _buildMiniInputField(
            key: Key('slot_series_${blockIndex}_${exerciseIndex}_$slotIndex'),
            label: 'SERIES',
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
          const SizedBox(width: AppSpacing.xs),

          // Reps
          _buildMiniInputField(
            key: Key('slot_reps_${blockIndex}_${exerciseIndex}_$slotIndex'),
            label: 'REPS',
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
          const SizedBox(width: AppSpacing.xs),

          // Peso
          _buildMiniInputField(
            key: Key('slot_peso_${blockIndex}_${exerciseIndex}_$slotIndex'),
            label: 'KG',
            value: detalle.peso,
            onChanged: (val) {
              controller.updateMemberParams(
                blockIndex: blockIndex,
                exerciseIndex: exerciseIndex,
                slotIndex: slotIndex,
                peso: val,
              );
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: AppTextStyles.labelCaps),
        const SizedBox(height: 4),
        SizedBox(
          width: 48,
          height: 28,
          child: TextFormField(
            initialValue: value,
            onChanged: onChanged,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelCaps,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceContainerHigh,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(AppRadius.sm),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
