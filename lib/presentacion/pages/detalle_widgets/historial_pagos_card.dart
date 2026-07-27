import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/presentacion/pages/detalle_widgets/pagos_filter_menu.dart';

class HistorialPagosCard extends StatelessWidget {
  final List<Pago> pagos;
  final bool isLoading;
  final Alumno alumno;
  final void Function(Pago) onEdit;
  final void Function(Pago) onDelete;
  final Function(String) onFilterSelected;

  const HistorialPagosCard({
    super.key,
    required this.pagos,
    required this.isLoading,
    required this.alumno,
    required this.onEdit,
    required this.onDelete,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.all(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historial de Pagos',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              PagosFilterMenu(onFilterSelected: onFilterSelected),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (pagos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'No hay pagos registrados este año',
                  style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                ),
              ),
            )
          else
            Column(
              children: pagos.map((pago) {
                final isTransferencia = pago.medioDePago == 'Transferencia';
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF141414,
                        ), // Fondo oscuro para el icono
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isTransferencia ? Icons.credit_card : Icons.payments,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          DateFormat(
                            'dd MMMM yyyy',
                            'es',
                          ).format(pago.fechaDePago),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isTransferencia
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isTransferencia
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : Colors.green.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            pago.medioDePago,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isTransferencia
                                  ? AppColors.primary
                                  : Colors.green[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Plan de ${pago.cantidadDias} días',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        if (pago.aplicaDescuento)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              'Descuento',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.blue[300],
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${NumberFormat.decimalPattern('es_AR').format(pago.monto)}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: AppColors.onSurfaceVariant,
                          ),
                          color: AppColors.surfaceContainerHigh,
                          onSelected: (value) {
                            if (value == 'editar') {
                              onEdit(pago);
                            } else if (value == 'eliminar') {
                              onDelete(pago);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem(
                              value: 'eliminar',
                              child: Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: Cargar historial completo
              },
              child: Text(
                'Ver pagos anteriores',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
