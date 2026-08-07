import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

class TotalRow extends StatelessWidget {
  final num total;

  const TotalRow({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 0,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('TOTAL INGRESOS', style: AppTextStyles.labelCaps),
        Text(
          format.format(total),
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
