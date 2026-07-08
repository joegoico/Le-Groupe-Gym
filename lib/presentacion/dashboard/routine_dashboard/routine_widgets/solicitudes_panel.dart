import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';

class SolicitudesPanel extends StatefulWidget {
  final List<SolicitudRutina> solicitudes;
  final VoidCallback onRegistrarSolicitud;
  final Function(SolicitudRutina) onResolverSolicitud;
  final Function(SolicitudRutina) onEliminarSolicitud;

  const SolicitudesPanel({
    super.key,
    required this.solicitudes,
    required this.onRegistrarSolicitud,
    required this.onResolverSolicitud,
    required this.onEliminarSolicitud,
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
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(
          top: AppRadius.xl,
          bottom: _expandido ? AppRadius.lg : AppRadius.xl,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          // ── Header — siempre visible ───────────────────────────────
          InkWell(
            onTap: () => setState(() => _expandido = !_expandido),
            borderRadius: BorderRadius.vertical(
              top: AppRadius.xl,
              bottom: _expandido ? Radius.zero : AppRadius.xl,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    _expandido
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Ícono del panel
                  Container(
                    width: 48,
                    height: 48,
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
                          style: AppTextStyles.labelCaps.copyWith(
                            fontSize: 10,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.solicitudes.length} Rutinas Pendientes',
                          style: AppTextStyles.headlineLg.copyWith(
                            fontSize: 22,
                            color: AppColors.primary,
                            letterSpacing: -0.3,
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

                  // Chevron
                ],
              ),
            ),
          ),

          // ── Lista colapsable ───────────────────────────────────────
          if (_expandido) ...[
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
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
                separatorBuilder: (_, _) => Divider(
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
                                (solicitud.alumnoNombre != null &&
                                        solicitud.alumnoApellido != null)
                                    ? '${solicitud.alumnoNombre} ${solicitud.alumnoApellido}'
                                    : 'ID: ${solicitud.idAlumno}',
                                style: AppTextStyles.subtittlesBold.copyWith(
                                  fontSize: 14,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              if (solicitud.notas != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  solicitud.notas!,
                                  style: AppTextStyles.subtittles.copyWith(
                                    fontSize: 13,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(solicitud.fechaSolicitud),
                                style: AppTextStyles.labelCaps.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
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
                            style: AppTextStyles.subtittlesBold.copyWith(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          onPressed: () =>
                              widget.onEliminarSolicitud(solicitud),
                          icon: const Icon(Icons.delete_outline_outlined),
                          color: AppColors.onSurfaceVariant,
                          style: IconButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(AppRadius.md),
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
