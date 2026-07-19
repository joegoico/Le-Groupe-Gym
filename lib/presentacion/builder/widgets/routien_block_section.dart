import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_builder_controller.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/inline_editable_text.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/routien_exercise_card.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/show_confirm_dialog.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/view_selector.dart';

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

  @override
  Widget build(BuildContext context) {
    return ViewSelector<String>(
      listenable: controller,
      selector: () {
        if (dayIndex >= controller.dias.length) return "";
        if (blockIndex >= controller.dias[dayIndex].bloques.length) return "";
        final currentBloque = controller.dias[dayIndex].bloques[blockIndex];

        final isActive =
            controller.activeBlockIndex == blockIndex &&
            controller.activeDayIndex == dayIndex;
        final canDelete = controller.bloques.length > 1;

        // Dependencias adicionales: si algún ejercicio cambia de estado superserie o combinando
        final exercisesState = currentBloque.ejercicios
            .asMap()
            .entries
            .map((e) {
              final isCombining = controller.isCombiningAt(blockIndex, e.key);
              return "${e.value.esSuperserie}_$isCombining";
            })
            .join("|");

        return "${currentBloque.nombre}_${currentBloque.ejercicios.length}_${isActive}_${canDelete}_$exercisesState";
      },
      builder: (context, _, __) {
        if (dayIndex >= controller.dias.length) return const SizedBox.shrink();
        if (blockIndex >= controller.dias[dayIndex].bloques.length)
          return const SizedBox.shrink();
        final currentBloque = controller.dias[dayIndex].bloques[blockIndex];

        final isActive =
            controller.activeBlockIndex == blockIndex &&
            controller.activeDayIndex == dayIndex;
        final canDeleteBlock = controller.bloques.length > 1;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => controller.selectBlock(dayIndex, blockIndex),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.surfaceContainerHigh
                : AppColors.surfaceContainerLow,
            borderRadius: const BorderRadius.all(AppRadius.lg),
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withOpacity(0.75)
                  : Colors.white.withOpacity(0.05),
              width: isActive ? 2 : 1,
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
                        width: isActive ? 10 : 6,
                        height: isActive ? 10 : 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant.withOpacity(0.3),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: InlineEditableText(
                          text: currentBloque.nombre,
                          style: AppTextStyles.titleMd,
                          onChanged: (newName) =>
                              controller.renameBlock(blockIndex, newName),
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.all(AppRadius.full),
                          ),
                          child: Text(
                            'ACTIVO',
                            style: AppTextStyles.labelCaps.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.08,
                            ),
                          ),
                        ),
                      if (canDeleteBlock)
                        Builder(
                          builder: (btnContext) => IconButton(
                            onPressed: () async {
                              final confirmed = await showConfirmDialog(
                                btnContext,
                                titulo: 'Eliminar bloque',
                                mensaje:
                                    '¿Estás seguro de que querés eliminar este bloque?',
                              );
                              if (!confirmed) return;
                              final ok = controller.removeBlock(blockIndex);
                              if (!ok)
                                onShowMessage?.call('No se pudo eliminar.');
                            },
                            tooltip: 'Eliminar bloque',
                            icon: const Icon(Icons.delete_rounded),
                            iconSize: 20,
                            color: AppColors.error.withOpacity(0.75),
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(7),
                              minimumSize: const Size(36, 36),
                              hoverColor: AppColors.error.withOpacity(0.15),
                              highlightColor: AppColors.error.withOpacity(0.25),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(AppRadius.sm),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: Colors.white.withOpacity(0.05)),

              // Contenido del bloque
              if (currentBloque.estaVacio)
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
                    itemCount: currentBloque.ejercicios.length,
                    itemBuilder: (context, exerciseIndex) {
                      return RoutineExerciseCard(
                        key: ValueKey('card_${blockIndex}_$exerciseIndex'),
                        blockIndex: blockIndex,
                        exerciseIndex: exerciseIndex,
                        item: currentBloque.ejercicios[exerciseIndex],
                        controller: controller,
                        onShowMessage: onShowMessage,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
  }
}
