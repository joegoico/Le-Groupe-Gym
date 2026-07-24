import 'package:flutter/material.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_builder_controller.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/show_confirm_dialog.dart';

class RoutineExerciseCard extends StatelessWidget {
  final int blockIndex;
  final int exerciseIndex;
  final EjercicioRutina item;
  final RoutineBuilderController controller;
  final void Function(String message)? onShowMessage;

  const RoutineExerciseCard({
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
              ? AppColors.tertiary.withValues(alpha: 0.65)
              : isCombining
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
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
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
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
                      child: Row(
                        children: [
                          Text('SUPERSERIE', style: AppTextStyles.labelCaps),
                          const SizedBox(width: AppSpacing.sm),
                          InkWell(
                            onTap: () => controller.uncombineExercise(
                              blockIndex,
                              exerciseIndex,
                            ),
                            borderRadius: const BorderRadius.all(AppRadius.sm),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              child: Text(
                                'Deshacer',
                                style: AppTextStyles.labelCaps.copyWith(
                                  color: AppColors.tertiary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          color: AppColors.primary.withValues(alpha: 0.8),
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
                tooltip: 'Mover a otro bloque',
                icon: Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.75),
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(7),
                  minimumSize: const Size(36, 36),
                  hoverColor: AppColors.onSurfaceVariant.withValues(
                    alpha: 0.12,
                  ),
                  highlightColor: AppColors.onSurfaceVariant.withValues(
                    alpha: 0.2,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppRadius.sm),
                  ),
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
            Builder(
              builder: (btnContext) => IconButton(
                icon: const Icon(Icons.delete_rounded),
                iconSize: 20,
                color: AppColors.error.withValues(alpha: 0.75),
                tooltip: 'Eliminar ejercicio',
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(7),
                  minimumSize: const Size(36, 36),
                  hoverColor: AppColors.error.withValues(alpha: 0.15),
                  highlightColor: AppColors.error.withValues(alpha: 0.25),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppRadius.sm),
                  ),
                ),
                onPressed: () async {
                  final confirmed = await showConfirmDialog(
                    btnContext,
                    titulo: 'Eliminar ejercicio',
                    mensaje:
                        '¿Estás seguro de que querés eliminar este ejercicio?',
                  );
                  if (!confirmed) return;
                  controller.removeExercise(blockIndex, exerciseIndex);
                },
              ),
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
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
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
