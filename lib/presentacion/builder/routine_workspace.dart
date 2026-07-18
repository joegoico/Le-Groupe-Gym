import 'package:flutter/material.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/show_confirm_dialog.dart';
import 'routine_builder_controller.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/routien_day_accordion.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/view_selector.dart';

class RoutineWorkspace extends StatefulWidget {
  final RoutineBuilderController controller;
  final void Function(String message)? onShowMessage;
  final TextEditingController notasController;

  const RoutineWorkspace({
    super.key,
    required this.controller,
    this.onShowMessage,
    required this.notasController,
  });

  @override
  State<RoutineWorkspace> createState() => _RoutineWorkspaceState();
}

class _RoutineWorkspaceState extends State<RoutineWorkspace> {
  // Día expandido — solo uno a la vez
  int? _expandedDay = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewSelector<(int, int)>(
      listenable: widget.controller,
      selector: () =>
          (widget.controller.dias.length, widget.controller.totalEjercicios),
      builder: (context, _, __) {
        return Container(
          color: AppColors.surfaceContainerLow,
          padding: const EdgeInsets.all(24.0),
          child: widget.controller.dias.isEmpty
              ? _buildEmptyState()
              : _buildRoutineWorkspace(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
            size: 56,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Zona de Armado de Rutinas', style: AppTextStyles.headlineLg),
          const SizedBox(height: AppSpacing.xs),
          Text('Agregá un día para empezar', style: AppTextStyles.titleMd),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => widget.controller.addDay(),
            icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
            label: Text('Agregar día', style: AppTextStyles.titleMd),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nueva Rutina de entrenamiento',
                    style: AppTextStyles.headlineLg,
                  ),
                  Text(
                    '${widget.controller.dias.length} días · ${widget.controller.totalEjercicios} ejercicios',
                    style: AppTextStyles.titleMd,
                  ),
                ],
              ),
            ),
            if (widget.controller.dias.length < 5)
              OutlinedButton.icon(
                onPressed: () {
                  widget.controller.addDay();
                  final newIndex = widget.controller.dias.length - 1;
                  setState(() => _expandedDay = newIndex);
                  widget.controller.selectDay(newIndex);
                },
                icon: const Icon(Icons.add, size: 14, color: AppColors.primary),
                label: Text('Agregar día', style: AppTextStyles.titleMd),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
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
              onPressed: () async {
                final ok = await showConfirmDialog(
                  context,
                  titulo: 'Limpiar rutina',
                  mensaje:
                      '¿Estás seguro de que querés eliminar toda la rutina?',
                );
                if (ok) widget.controller.clearRoutine();
              },
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

        // Lista de días
        Expanded(
          child: ListView.builder(
            itemCount: widget.controller.dias.length,
            itemBuilder: (context, dayIndex) {
              final dia = widget.controller.dias[dayIndex];
              final isExpanded = _expandedDay == dayIndex;

              return RoutineDayAccordion(
                key: ValueKey('day_$dayIndex'),
                dayIndex: dayIndex,
                dia: dia,
                isExpanded: isExpanded,
                controller: widget.controller,
                onToggle: () {
                  setState(() {
                    if (isExpanded) {
                      // Colapsar el día activo
                      _expandedDay = null;
                      if (widget.controller.activeDayIndex == dayIndex) {
                        widget.controller.deselectDay();
                      }
                    } else {
                      // Abrir este y cerrar el anterior automáticamente
                      _expandedDay = dayIndex;
                      widget.controller.selectDay(dayIndex);
                    }
                  });
                },
                onShowMessage: widget.onShowMessage,
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Campo de notas generales
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: const BorderRadius.all(AppRadius.lg),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('NOTAS GENERALES', style: AppTextStyles.labelCaps),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                key: const Key('notas_generales_field'),
                controller: widget.notasController,
                maxLines: 4,
                style: AppTextStyles.subtittles,
                decoration: InputDecoration(
                  hintText:
                      'Agregá notas o indicaciones generales para el alumno...',
                  hintStyle: AppTextStyles.subtittles.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(AppRadius.md),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(AppRadius.md),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      // Al final de _buildWorkspace(), después del ListView de días
    );
  }
}
