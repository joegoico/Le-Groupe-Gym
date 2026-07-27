import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/data/models/deudor_model.dart';
import 'package:le_groupe_gym/presentacion/pages/detalle_widgets/detalle_card.dart';

class EstadoCuentaCard extends StatelessWidget {
  final Pago? ultimoPago;
  final Deudor? deudor;

  const EstadoCuentaCard({
    super.key,
    required this.ultimoPago,
    this.deudor,
  });

  @override
  Widget build(BuildContext context) {
    bool esDeudor = false;
    int diasVencido = 0;
    
    if (deudor != null && deudor!.diasAdeudados > 0) {
      esDeudor = true;
      diasVencido = deudor!.diasAdeudados;
    }

    final Color statusColor = esDeudor ? Colors.redAccent : AppColors.primary;
    final String statusText = esDeudor ? 'Cuota Vencida' : 'Cuota al Día';
    final IconData statusIcon = esDeudor ? Icons.cancel_outlined : Icons.check_circle_outline;

    return DetalleCard(
      accentLeft: true,
      accentColor: statusColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ESTADO DE CUENTA',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                'Próximo Venc.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: esDeudor ? Colors.redAccent : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 20,
                      ),
                    ],
                  ),
                  if (esDeudor) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'HACE $diasVencido DÍAS',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              Text(
                ultimoPago != null
                    ? DateFormat('dd/MM/yyyy').format(ultimoPago!.fechaDePago)
                    : '-',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Último pago: ${ultimoPago != null ? DateFormat('MM/yyyy').format(ultimoPago!.fechaDePago) : 'N/A'}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                ultimoPago != null ? '\$${ultimoPago!.monto.toInt()}' : '\$0',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
