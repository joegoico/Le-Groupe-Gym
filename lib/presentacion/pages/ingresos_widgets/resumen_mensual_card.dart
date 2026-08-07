import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/resumen_mensual_model.dart';
import 'package:le_groupe_gym/presentacion/pages/ingresos_widgets/desglose_row.dart';
import 'package:le_groupe_gym/presentacion/pages/ingresos_widgets/total_row.dart';

class ResumenMensualCard extends StatelessWidget {
  final ResumenMensual resumen;
  final VoidCallback onVerDetalle;

  const ResumenMensualCard({
    super.key,
    required this.resumen,
    required this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // — Cabecera —
          Text(
            resumen.titulo,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Balance consolidado mensual', style: AppTextStyles.subtittles),

          const SizedBox(height: AppSpacing.lg),

          // — Total —
          TotalRow(total: resumen.total),

          const SizedBox(height: AppSpacing.md),

          // — Desglose —
          DesgloseRow(titulo: 'Efectivo', monto: resumen.totalEfectivo),
          DesgloseRow(
            titulo: 'Transferencia',
            monto: resumen.totalTransferencia,
          ),

          const SizedBox(height: AppSpacing.md),

          // — Botón —
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onVerDetalle,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(AppRadius.md),
                ),
              ),
              child: Text(
                'Ver Detalles del Mes →',
                style: AppTextStyles.buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
