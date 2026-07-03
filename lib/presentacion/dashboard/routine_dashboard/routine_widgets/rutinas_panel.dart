import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';

class RutinasPanel extends StatelessWidget {
  final List<({Rutina rutina, Alumno alumno})> rutinas;
  final Function(Rutina) onVerDetalle;

  const RutinasPanel({
    super.key,
    required this.rutinas,
    required this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Últimas rutinas realizadas',
                  style: AppTextStyles.headlineLg,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Lista o vacío
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
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: const BorderRadius.all(AppRadius.lg),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rutinas.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.05),
              ),
              itemBuilder: (context, index) {
                final item = rutinas[index];
                return InkWell(
                  onTap: () => onVerDetalle(item.rutina),
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? AppRadius.lg : Radius.zero,
                    bottom: index == rutinas.length - 1
                        ? AppRadius.lg
                        : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        // Ícono
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: const BorderRadius.all(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.rutina.nombre,
                                style: AppTextStyles.titleMd,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.alumno.nombreCompleto,
                                      style: GoogleFonts.inter(
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
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Icon(
                                      Icons.access_time,
                                      size: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      _formatDate(item.rutina.fechaCreacion!),
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 11,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Flecha
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
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

  String _formatDate(DateTime date) {
    final hora =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
    return '$hora';
  }
}
