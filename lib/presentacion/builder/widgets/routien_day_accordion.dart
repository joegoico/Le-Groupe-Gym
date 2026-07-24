import 'package:le_groupe_gym/data/models/dia_rutina_model.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_builder_controller.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/inline_editable_text.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/routien_block_section.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/show_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/view_selector.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:flutter/material.dart';

class RoutineDayAccordion extends StatelessWidget {
  final int dayIndex;
  final DiaRutina dia;
  final bool isExpanded;
  final RoutineBuilderController controller;
  final VoidCallback onToggle;
  final void Function(String)? onShowMessage;

  const RoutineDayAccordion({
    super.key,
    required this.dayIndex,
    required this.dia,
    required this.isExpanded,
    required this.controller,
    required this.onToggle,
    this.onShowMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ViewSelector<String>(
      listenable: controller,
      selector: () {
        if (dayIndex >= controller.dias.length) return "";
        final currentDia = controller.dias[dayIndex];
        final isActive = controller.activeDayIndex == dayIndex;
        return "${currentDia.nombre}_${currentDia.bloques.length}_${currentDia.bloques.fold(0, (sum, b) => sum + b.ejercicios.length)}_${isExpanded}_$isActive";
      },
      builder: (context, _, __) {
        if (dayIndex >= controller.dias.length) return const SizedBox.shrink();
        final currentDia = controller.dias[dayIndex];
        final isActiveDay = controller.activeDayIndex == dayIndex;

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: isExpanded
                ? AppColors.surfaceContainerHigh
                : AppColors.surfaceContainerLow,
            borderRadius: const BorderRadius.all(AppRadius.lg),
            border: Border.all(
              color: isExpanded
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.05),
              width: isExpanded ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Header del día — tap para colapsar/expandir
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.vertical(
                  top: AppRadius.lg,
                  bottom: isExpanded ? Radius.zero : AppRadius.lg,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        color: isExpanded
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        size: isExpanded ? 22 : 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: InlineEditableText(
                          text: currentDia.nombre,
                          style: AppTextStyles.titleMd,
                          onChanged: (newName) =>
                              controller.renameDay(dayIndex, newName),
                        ),
                      ),
                      // Badge día activo
                      if (isActiveDay) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: const BorderRadius.all(
                              AppRadius.full,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'ACTIVO',
                                style: AppTextStyles.labelCaps.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: const BorderRadius.all(AppRadius.full),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Text(
                          '${currentDia.bloques.fold(0, (sum, b) => sum + b.ejercicios.length)} ejercicios',
                          style: AppTextStyles.labelCaps.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                            letterSpacing: 0.03,
                          ),
                        ),
                      ),
                      if (controller.dias.length > 1)
                        Builder(
                          builder: (btnContext) => IconButton(
                            onPressed: () async {
                              final confirmed = await showConfirmDialog(
                                btnContext,
                                titulo: 'Eliminar día',
                                mensaje:
                                    '¿Estás seguro de que querés eliminar este día?',
                              );
                              if (!confirmed) return;
                              final ok = controller.removeDay(dayIndex);
                              if (!ok) {
                                onShowMessage?.call(
                                  'No se puede eliminar el único día.',
                                );
                              }
                            },
                            tooltip: 'Eliminar día',
                            icon: const Icon(Icons.delete_rounded),
                            iconSize: 20,
                            color: AppColors.error.withValues(alpha: 0.75),
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(7),
                              minimumSize: const Size(36, 36),
                              hoverColor: AppColors.error.withValues(
                                alpha: 0.15,
                              ),
                              highlightColor: AppColors.error.withValues(
                                alpha: 0.25,
                              ),
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

              // Contenido colapsable
              if (isExpanded) ...[
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    children: [
                      // Bloques del día
                      ...currentDia.bloques.asMap().entries.map((entry) {
                        return RoutineBlockSection(
                          key: ValueKey('block_${dayIndex}_${entry.key}'),
                          dayIndex: dayIndex,
                          blockIndex: entry.key,
                          bloque: entry.value,
                          controller: controller,
                          onShowMessage: onShowMessage,
                        );
                      }),

                      // Botón agregar bloque
                      TextButton.icon(
                        onPressed: () {
                          controller.selectDay(dayIndex);
                          controller.addBlock();
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'Agregar bloque',
                          style: AppTextStyles.titleMd,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
