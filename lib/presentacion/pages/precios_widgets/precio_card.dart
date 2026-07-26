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

  bool _isRecomendado() => precio.cantidadDias == 30;

  String _getPlanName() {
    if (precio.cantidadDias == 30) return 'Pase Libre';
    if (precio.cantidadDias == 7) return 'Pase Semanal';
    return 'Plan de ${precio.cantidadDias} días';
  }

  String _getPeriodo() {
    if (precio.cantidadDias == 30) return 'mes';
    if (precio.cantidadDias == 1) return 'día';
    if (precio.cantidadDias == 7) return 'sem';
    return '${precio.cantidadDias} d';
  }

  List<({bool included, String text})> _getFeatures() {
    if (precio.cantidadDias >= 30) {
      return [
        (included: true, text: 'Acceso sala musculación'),
        (included: true, text: 'Clases funcional'),
        (included: true, text: 'Sin límite horario'),
      ];
    } else {
      return [
        (included: true, text: 'Acceso por ${precio.cantidadDias} días'),
        (included: true, text: 'Sala de musculación'),
        (included: true, text: 'Clases funcional'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer, // Fondo oscuro similar al mockup
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(
          color: _isRecomendado()
              ? AppColors.primary.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior (Badge y Botones de acción)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isRecomendado())
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'RECOMENDADO',
                    style: AppTextStyles.labelCaps.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                )
              else
                const SizedBox(
                  height: 22,
                ), // Espacio para mantener alineación si no hay badge

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => onEditar(precio),
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      hoverColor: AppColors.primary.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  IconButton(
                    onPressed: () => onEliminar(precio),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.error.withValues(alpha: 0.8),
                    ),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      hoverColor: AppColors.error.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Título del plan
          Text(
            _getPlanName(),
            style: AppTextStyles.titleCards.copyWith(
              color: AppColors.onSurface,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '\$',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  _formatValor(precio.valor),
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ ${_getPeriodo()}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Precio y periodo
          const SizedBox(height: AppSpacing.lg),

          // Lista de características
          ..._getFeatures().map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    feature.included
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    size: 18,
                    color: feature.included
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      feature.text,
                      style: AppTextStyles.subtittles.copyWith(
                        color: feature.included
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
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
