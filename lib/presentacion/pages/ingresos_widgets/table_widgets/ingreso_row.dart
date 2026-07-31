import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/ingreso_model.dart';
import 'package:le_groupe_gym/presentacion/pages/ingresos_widgets/medio_pago_badge.dart';

class IngresoRow extends StatelessWidget {
  final Ingreso ingreso;
  final DateFormat dateFmt;
  final NumberFormat montoFmt;

  const IngresoRow({
    super.key,
    required this.ingreso,
    required this.dateFmt,
    required this.montoFmt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  dateFmt.format(ingreso.fechaIngreso),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  ingreso.concepto,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: MedioPagoBadge(medioDePago: ingreso.medioDePago ?? '—'),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '+ ${montoFmt.format(ingreso.monto)}',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.outlineVariant),
      ],
    );
  }
}
