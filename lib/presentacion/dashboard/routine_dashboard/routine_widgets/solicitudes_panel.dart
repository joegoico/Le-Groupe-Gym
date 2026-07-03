import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';

class SolicitudesPanel extends StatefulWidget {
  final List<SolicitudRutina> solicitudes;
  final VoidCallback onRegistrarSolicitud;
  final Function(SolicitudRutina) onResolverSolicitud;

  const SolicitudesPanel({
    super.key,
    required this.solicitudes,
    required this.onRegistrarSolicitud,
    required this.onResolverSolicitud,
  });

  @override
  State<SolicitudesPanel> createState() => _SolicitudesPanelState();
}

class _SolicitudesPanelState extends State<SolicitudesPanel> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Header — siempre visible
          InkWell(
            onTap: () => setState(() => _expandido = !_expandido),
            borderRadius: BorderRadius.vertical(
              top: AppRadius.lg,
              bottom: _expandido ? Radius.zero : AppRadius.lg,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  // Ícono
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: const BorderRadius.all(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Contador
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SOLICITUDES ACTUALES',
                          style: GoogleFonts.robotoMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () => setState(() => _expandido = !_expandido),
                          child: Text(
                            '${widget.solicitudes.length} Rutinas Pendientes',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botón registrar
                  ElevatedButton.icon(
                    onPressed: widget.onRegistrarSolicitud,
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: Text(
                      'Registrar solicitud',
                      style: AppTextStyles.buttonText,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    _expandido
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Lista colapsable
          if (_expandido) ...[
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            if (widget.solicitudes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Text(
                    'No hay solicitudes pendientes',
                    style: AppTextStyles.labelCaps,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.solicitudes.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                itemBuilder: (context, index) {
                  final solicitud = widget.solicitudes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                solicitud.idAlumno,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              if (solicitud.notas != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  solicitud.notas!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(solicitud.fechaSolicitud),
                                style: GoogleFonts.robotoMono(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              widget.onResolverSolicitud(solicitud),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(AppRadius.md),
                            ),
                          ),
                          child: Text(
                            'Resolver',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
