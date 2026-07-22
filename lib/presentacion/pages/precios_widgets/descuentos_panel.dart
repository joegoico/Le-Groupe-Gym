import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';
import 'package:le_groupe_gym/presentacion/pages/precios_widgets/descuento_item.dart';

class DescuentosPanel extends StatelessWidget {
  final List<Descuento> descuentos;
  final VoidCallback onAgregarDescuento;
  final Function(Descuento) onEliminarDescuento;
  final Function(Descuento) onEditarDescuento;

  const DescuentosPanel({
    required this.descuentos,
    required this.onAgregarDescuento,
    required this.onEliminarDescuento,
    required this.onEditarDescuento,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.lg,
        right: AppSpacing.md,
        bottom: AppSpacing.lg,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Descuentos',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: onAgregarDescuento,
                  tooltip: 'Agregar descuento',
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.10),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.sm),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Items o empty state
          if (descuentos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Sin descuentos activos',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            )
          else
            ...descuentos.map(
              (descuento) => DescuentoItem(
                descuento: descuento,
                onEliminar: () => onEliminarDescuento(descuento),
                onEditar: () => onEditarDescuento(descuento),
              ),
            ),
        ],
      ),
    );
  }
}
