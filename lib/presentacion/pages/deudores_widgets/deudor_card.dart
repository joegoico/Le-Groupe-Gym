import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/deudor_model.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';

class DeudorCard extends ConsumerWidget {
  final Deudor deudor;
  final VoidCallback onRegistrarPago;
  final VoidCallback? onEnviarMensaje;

  const DeudorCard({
    super.key,
    required this.deudor,
    required this.onRegistrarPago,
    this.onEnviarMensaje,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Definir color de severidad
    final Color severityColor =
        deudor.diasAdeudados >= 30 ? Colors.redAccent : Colors.orangeAccent;

    // Fetch último pago
    final ultimoPagoRepo = ref.watch(pagoRepositoryProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(AppRadius.lg),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Borde izquierdo de severidad
              Container(width: 4, color: severityColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: FutureBuilder(
                    future: ultimoPagoRepo.getUltimoPago(deudor.idDeudor),
                    builder: (context, snapshot) {
                      final ultimoPago = snapshot.data;
                      final planNombre = ultimoPago != null
                          ? 'Plan de ${ultimoPago.cantidadDias} días'
                          : 'Sin plan reciente';
                      final fechaStr = ultimoPago != null
                          ? DateFormat("d 'de' MMMM", "es").format(ultimoPago.fechaDePago)
                          : 'N/A';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header (Avatar y Nombre)
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                child: Text(
                                  deudor.nombre.isNotEmpty
                                      ? deudor.nombre[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deudor.nombreCompleto,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      planNombre,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Contenedor oscuro central (Estado de deuda)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Badge Hace X dias
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: severityColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'HACE ${deudor.diasAdeudados} DÍAS',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: severityColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Último pago:',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      fechaStr,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),

                          // Footer (Acciones)
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed: onEnviarMensaje,
                                  icon: const Icon(Icons.email_outlined),
                                  color: AppColors.onSurfaceVariant,
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: onRegistrarPago,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD0FD38),
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(AppRadius.md),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  child: Text(
                                    'Registrar Pago',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
