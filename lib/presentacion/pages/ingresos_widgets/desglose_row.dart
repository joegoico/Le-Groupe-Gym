import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

class DesgloseRow extends StatelessWidget {
  final String titulo;
  final num monto;

  const DesgloseRow({super.key, required this.titulo, required this.monto});

  static IconData _icon(String titulo) {
    if (titulo.toLowerCase() == 'transferencia') return Icons.credit_card;
    return Icons.payments;
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 0);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: const BorderRadius.all(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.all(AppRadius.sm),
            ),
            child: Icon(_icon(titulo), color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              titulo,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Text(
            format.format(monto),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
