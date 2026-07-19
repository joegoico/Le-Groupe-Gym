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

  Future<void> _confirmarEliminar(
    BuildContext context,
    SolicitudRutina solicitud,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
          side: BorderSide(
            color: AppColors.surfaceContainerHighest,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        titlePadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.all(AppRadius.md),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 22,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '¿Eliminar solicitud?',
              style: AppTextStyles.titleMd,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta acción es permanente y no se puede deshacer. ¿Querés eliminar esta solicitud?',
              style: AppTextStyles.subtittles.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(
              color: AppColors.surfaceContainerHighest,
              thickness: 1,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm + 2,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                        side: BorderSide(
                          color: AppColors.surfaceContainerHighest,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: AppTextStyles.subtittlesBold.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorContainer,
                      foregroundColor: AppColors.error,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm + 2,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      'Eliminar',
                      style: AppTextStyles.subtittlesBold.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
    );

    if (confirmar == true) {
      widget.onEliminarSolicitud(solicitud);
    }
  }

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
                              _confirmarEliminar(context, solicitud),
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
