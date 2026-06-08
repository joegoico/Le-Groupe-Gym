import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_builder_controller.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/inline_editable_text.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/routien_exercise_card.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/show_confirm_dialog.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';

class RoutineBlockSection extends StatelessWidget {
  final int blockIndex;
  final int dayIndex;
  final BloqueRutina bloque;
  final RoutineBuilderController controller;
  final void Function(String message)? onShowMessage;

  const RoutineBlockSection({
    required this.dayIndex,
    super.key,
    required this.blockIndex,
    required this.bloque,
    required this.controller,
    this.onShowMessage,
  });

  // _RoutineBlockSection — rediseñado:
  @override
  Widget build(BuildContext context) {
    final isActive =
        controller.activeBlockIndex == blockIndex &&
        controller.activeDayIndex == dayIndex;
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
            onTap: () => controller.selectBlock(dayIndex, blockIndex),
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
                    child: InlineEditableText(
                      text: bloque.nombre,
                      style: AppTextStyles.titleMd,
                      onChanged: (newName) =>
                          controller.renameBlock(blockIndex, newName),
                    ),
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
                    Builder(
                      builder: (btnContext) => IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppColors.onSurfaceVariant.withOpacity(0.5),
                          size: 16,
                        ),
                        onPressed: () async {
                          final confirmed = await showConfirmDialog(
                            btnContext,
                            titulo: 'Eliminar bloque',
                            mensaje:
                                '¿Estás seguro de que querés eliminar este bloque?',
                          );
                          if (!confirmed) return;
                          final ok = controller.removeBlock(blockIndex);
                          if (!ok) onShowMessage?.call('No se pudo eliminar.');
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
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
                  return RoutineExerciseCard(
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
