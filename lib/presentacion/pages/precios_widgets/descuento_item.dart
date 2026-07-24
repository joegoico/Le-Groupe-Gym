import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';

class DescuentoItem extends StatelessWidget {
  final Descuento descuento;
  final VoidCallback onEliminar;
  final VoidCallback onEditar;

  const DescuentoItem({
    required this.descuento,
    required this.onEliminar,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: const BorderRadius.all(AppRadius.md),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            // Badge de monto — ocupa el espacio disponible
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.all(AppRadius.sm),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  '\$${descuento.valor}',
                  style: GoogleFonts.robotoMono(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            // Botón editar
            IconButton(
              onPressed: onEditar,
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.xs),
                minimumSize: const Size(32, 32),
                hoverColor: AppColors.primary.withValues(alpha: 0.10),
                highlightColor: AppColors.primary.withValues(alpha: 0.18),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(AppRadius.sm),
                ),
              ),
            ),
            // Botón eliminar
            IconButton(
              onPressed: onEliminar,
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.error,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.xs),
                minimumSize: const Size(32, 32),
                hoverColor: AppColors.error.withValues(alpha: 0.10),
                highlightColor: AppColors.error.withValues(alpha: 0.18),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(AppRadius.sm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
