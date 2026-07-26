import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/presentacion/pages/detalle_widgets/detalle_card.dart';
import 'package:le_groupe_gym/presentacion/pages/detalle_widgets/detalle_rutina_tile.dart';

class RutinasAsignadasCard extends StatelessWidget {
  final AsyncValue<List<({Rutina rutina, Alumno alumno})>> rutinasAsync;

  const RutinasAsignadasCard({
    super.key,
    required this.rutinasAsync,
  });

  @override
  Widget build(BuildContext context) {
    return DetalleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RUTINAS ASIGNADAS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          rutinasAsync.when(
            data: (lista) {
              if (lista.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  child: Text(
                    'No tiene rutinas asignadas',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return Column(
                children: lista.map((item) {
                  final rutina = item.rutina;
                  final diasText = '${rutina.dias.length} días/semana';
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.sm,
                    ),
                    child: DetalleRutinaTile(
                      icon: Icons.fitness_center,
                      title: rutina.nombre,
                      subtitle: diasText,
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
              child: Text(
                'Error cargando rutinas: $err',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
