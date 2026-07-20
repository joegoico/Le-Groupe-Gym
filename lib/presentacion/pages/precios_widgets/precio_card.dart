import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';

class PrecioCard extends StatelessWidget {
  final Precio precio;
  final ValueChanged<Precio> onEditar;
  final ValueChanged<Precio> onEliminar;

  const PrecioCard({
    super.key,
    required this.precio,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${precio.cantidadDias} días',
                  style: AppTextStyles.subtittles,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => onEditar(precio),
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => onEliminar(precio),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: AppColors.error,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '\$ ${_formatValor(precio.valor)}',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          Text(
            '/ mes',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValor(int valor) {
    return valor.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
