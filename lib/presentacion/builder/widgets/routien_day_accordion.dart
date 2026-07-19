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
        return "${currentDia.nombre}_${currentDia.bloques.length}_${currentDia.bloques.fold(0, (sum, b) => sum + b.ejercicios.length)}_${isExpanded}";
      },
      builder: (context, _, __) {
        if (dayIndex >= controller.dias.length) return const SizedBox.shrink();
        final currentDia = controller.dias[dayIndex];

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: const BorderRadius.all(AppRadius.lg),
            border: Border.all(
              color: isExpanded
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
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
                        color: AppColors.primary,
                        size: 20,
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
                      Text(
                        '${currentDia.bloques.fold(0, (sum, b) => sum + b.ejercicios.length)} ejercicios',
                        style: AppTextStyles.titleMd,
                      ),
                      if (controller.dias.length > 1)
                        Builder(
                          builder: (btnContext) => IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: AppColors.onSurfaceVariant.withOpacity(
                                0.5,
                              ),
                              size: 16,
                            ),
                            onPressed: () async {
                              final confirmed = await showConfirmDialog(
                                btnContext,
                                titulo: 'Eliminar día',
                                mensaje:
                                    '¿Estás seguro de que querés eliminar este día?',
                              );
                              if (!confirmed) return;
                              final ok = controller.removeDay(dayIndex);
                              if (!ok)
                                onShowMessage?.call(
                                  'No se puede eliminar el único día.',
                                );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
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
