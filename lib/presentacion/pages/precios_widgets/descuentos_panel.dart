import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';
import 'package:le_groupe_gym/presentacion/pages/precios_widgets/descuento_item.dart';

class DescuentosPanel extends StatelessWidget {
  final List<Descuento> descuentos;
  final VoidCallback onAgregarDescuento;
  final Function(Descuento) onEliminarDescuento;

  const DescuentosPanel({
    required this.descuentos,
    required this.onAgregarDescuento,
    required this.onEliminarDescuento,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Gestión de Descuentos',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: onAgregarDescuento,
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Descuentos Aplicables',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...descuentos.map(
            (descuento) => DescuentoItem(
              descuento: descuento,
              onEliminar: () => onEliminarDescuento(descuento),
            ),
          ),
        ],
      ),
    );
  }
}
