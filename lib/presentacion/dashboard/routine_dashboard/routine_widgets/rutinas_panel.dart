import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';

class RutinasPanel extends StatelessWidget {
  final List<({Rutina rutina, Alumno alumno})> rutinas;
  final Function(Rutina) onVerDetalle;
  final Function(Rutina)? onEditarRutina;
  final Function(Rutina)? onEliminarRutina;
  final VoidCallback? onVerHistorial;

  const RutinasPanel({
    super.key,
    required this.rutinas,
    required this.onVerDetalle,
    this.onEditarRutina,
    this.onEliminarRutina,
    this.onVerHistorial,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Encabezado ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimas 10 realizadas',
                style: AppTextStyles.titleMd,
                overflow: TextOverflow.ellipsis,
              ),
              if (onVerHistorial != null)
                GestureDetector(
                  onTap: onVerHistorial,
                  child: Text(
                    'VER HISTORIAL COMPLETO',
                    style: AppTextStyles.labelCaps.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Lista o vacío ─────────────────────────────────────────────
        if (rutinas.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'No hay rutinas registradas',
                style: AppTextStyles.labelCaps,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rutinas.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final item = rutinas[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: const BorderRadius.all(AppRadius.md),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    // ── Ícono ────────────────────────────────────
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: const BorderRadius.all(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // ── Info ─────────────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.rutina.nombre,
                            style: AppTextStyles.subtittlesBold.copyWith(
                              fontSize: 14,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.alumno.nombreCompleto,
                                  style: AppTextStyles.subtittlesBold.copyWith(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.rutina.fechaCreacion != null) ...[
                                Text(
                                  ' · ',
                                  style: AppTextStyles.subtittles.copyWith(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Icon(
                                  _dateIcon(item.rutina.fechaCreacion!),
                                  size: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  _formatRelativeDate(
                                    item.rutina.fechaCreacion!,
                                  ),
                                  style: AppTextStyles.labelCaps.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Acciones ─────────────────────────────────
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () => onVerDetalle(item.rutina),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(AppRadius.md),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Ver',
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        onPressed: onEditarRutina != null
                            ? () => onEditarRutina!(item.rutina)
                            : null,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.edit_outlined, size: 15),
                        color: AppColors.onSurfaceVariant,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    if (onEliminarRutina != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          onPressed: () => onEliminarRutina!(item.rutina),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.delete_outline, size: 15),
                          color: AppColors.error,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.error.withValues(
                              alpha: 0.1,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(AppRadius.md),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  /// "DD/MM/YYYY"
  String _formatRelativeDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  IconData _dateIcon(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    return dateDay == today ? Icons.access_time : Icons.history;
  }
}
