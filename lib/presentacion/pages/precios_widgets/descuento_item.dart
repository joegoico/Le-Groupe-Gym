import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';

class DescuentoItem extends StatelessWidget {
  final Descuento descuento;
  final VoidCallback onEliminar;

  const DescuentoItem({required this.descuento, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: const BorderRadius.all(AppRadius.sm),
              ),
              child: Text(
                '${descuento.valor}',
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onEliminar,
            icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
