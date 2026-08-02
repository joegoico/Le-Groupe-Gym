import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:google_fonts/google_fonts.dart';

class RutinasPredeterminadasPanel extends StatelessWidget {
  final List<Rutina> rutinas;
  final VoidCallback onNuevaRutina;
  final Function(Rutina) onVerDetalle;
  final Function(Rutina)? onEditarRutina;
  final Function(Rutina)? onEliminarRutina;
  final Function(Rutina) onAsignarRutina;

  const RutinasPredeterminadasPanel({
    super.key,
    required this.rutinas,
    required this.onNuevaRutina,
    required this.onVerDetalle,
    this.onEditarRutina,
    this.onEliminarRutina,
    required this.onAsignarRutina,
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
              Expanded(
                child: Text(
                  'Rutinas Genéricas',
                  style: AppTextStyles.titleMd,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onNuevaRutina,
                icon: const Icon(Icons.add, size: 14),
                label: Text(
                  'Nueva rutina genérica',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppRadius.md),
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
                'No hay rutinas predeterminadas registradas',
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
              final rutina = rutinas[index];
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
                            rutina.nombre,
                            style: AppTextStyles.titleCards,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    // ── Botón Asignar ───────────────────────────
                    TextButton.icon(
                      onPressed: () => onAsignarRutina(rutina),
                      icon: const Icon(Icons.send_outlined, size: 16),
                      label: Text(
                        'Asignar',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),

                    // ── Acciones ─────────────────────────────────
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.onSurfaceVariant,
                        size: 20,
                      ),
                      color: AppColors.surfaceContainerHigh,
                      onSelected: (value) {
                        if (value == 'ver') {
                          onVerDetalle(rutina);
                        } else if (value == 'editar' &&
                            onEditarRutina != null) {
                          onEditarRutina!(rutina);
                        } else if (value == 'eliminar' &&
                            onEliminarRutina != null) {
                          onEliminarRutina!(rutina);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'ver',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf_outlined,
                                size: 18,
                                color: AppColors.onSurface,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text('Ver PDF', style: AppTextStyles.subtittles),
                            ],
                          ),
                        ),
                        if (onEditarRutina != null)
                          PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.onSurface,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text('Editar', style: AppTextStyles.subtittles),
                              ],
                            ),
                          ),
                        if (onEliminarRutina != null)
                          PopupMenuItem(
                            value: 'eliminar',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Eliminar',
                                  style: AppTextStyles.subtittles.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
