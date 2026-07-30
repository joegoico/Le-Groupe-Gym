import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

/// Badge/Chip para mostrar el medio de pago en la tabla de ingresos.
/// Efectivo → borde verde flúor. Transferencia → borde morado.
class MedioPagoBadge extends StatelessWidget {
  final String medioDePago;

  const MedioPagoBadge({super.key, required this.medioDePago});

  static const _purple = Color(0xFFADC6FF);

  @override
  Widget build(BuildContext context) {
    final isTransferencia = medioDePago.toLowerCase() == 'transferencia';
    final color = isTransferencia ? _purple : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        medioDePago,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
