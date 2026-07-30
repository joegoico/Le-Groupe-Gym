import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

/// Tarjeta horizontal que muestra el total de un medio de pago.
class TotalCard extends StatelessWidget {
  final String titulo;
  final num monto;
  final IconData icon;

  const TotalCard({
    super.key,
    required this.titulo,
    required this.monto,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: AppTextStyles.labelCaps),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  format.format(monto),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
        ],
      ),
    );
  }
}
