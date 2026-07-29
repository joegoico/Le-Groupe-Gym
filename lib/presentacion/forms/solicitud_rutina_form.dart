import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/data/repositories/alumno_repository.dart';
import 'package:le_groupe_gym/data/repositories/solicitud_rutina_repository.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/repositories/pago_repository.dart';
import 'package:le_groupe_gym/data/repositories/deudor_repository.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/show_confirm_dialog.dart';

class AddSolicitudRutinaForm extends StatefulWidget {
  final VoidCallback onCancelar;
  final ValueChanged<SolicitudRutina> onGuardar;
  final AlumnoRepository alumnoRepository;
  final SolicitudRutinaRepository solicitudRutinaRepository;
  final PagoRepository pagoRepository;
  final DeudorRepository deudorRepository;

  const AddSolicitudRutinaForm({
    super.key,
    required this.onCancelar,
    required this.onGuardar,
    required this.alumnoRepository,
    required this.solicitudRutinaRepository,
    required this.pagoRepository,
    required this.deudorRepository,
  });

  @override
  State<AddSolicitudRutinaForm> createState() => _AddSolicitudRutinaFormState();
}

class _AddSolicitudRutinaFormState extends State<AddSolicitudRutinaForm> {
  final TextEditingController _nombreRutinaController = TextEditingController();
  Alumno? _selectedAlumno;
  bool _isSaving = false;

  bool get _canSave =>
      !_isSaving &&
      _selectedAlumno != null &&
      _nombreRutinaController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nombreRutinaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nombreRutinaController.dispose();
    super.dispose();
  }

  Future<void> _guardarSolicitudRutina() async {
    if (!_canSave) return;

    setState(() => _isSaving = true);

    final solicitudRutina = SolicitudRutina(
      idAlumno: _selectedAlumno!.idAlumno,
      fechaSolicitud: DateTime.now(),
      notas: _nombreRutinaController.text.trim(),
    );

    try {
      final deudores = await widget.deudorRepository.getDeudores();
      final deudorIndex = deudores.indexWhere((d) => d.idDeudor == _selectedAlumno!.idAlumno);
      final isDebtor = deudorIndex != -1;
      final diasAdeudados = isDebtor ? deudores[deudorIndex].diasAdeudados : 0;

      final ultimoPago = await widget.pagoRepository.getUltimoPago(_selectedAlumno!.idAlumno);
      final hasNoPayments = ultimoPago == null;

      if (isDebtor || hasNoPayments) {
        if (mounted) setState(() => _isSaving = false);

        String alertMessage = '';
        if (isDebtor && !hasNoPayments) {
          alertMessage = 'El alumno se encuentra en situación de deudor (hace $diasAdeudados días).';
        } else if (!isDebtor && hasNoPayments) {
          alertMessage = 'El alumno no registra pagos.';
        } else {
          alertMessage = 'El alumno es deudor (hace $diasAdeudados días) y no registra pagos.';
        }

        alertMessage += '\n\n¿Desea continuar de todas formas?';

        final proceed = await showConfirmDialog(
          context,
          titulo: 'Advertencia',
          mensaje: alertMessage,
          confirmLabel: 'Continuar',
          confirmColor: AppColors.warningLow,
          headerIcon: Icons.warning_amber_rounded,
        );

        if (proceed != true) return;
        if (mounted) setState(() => _isSaving = true);
      }


      final idSolicitud = await widget.solicitudRutinaRepository
          .createSolicitud(solicitudRutina);
      widget.onGuardar(solicitudRutina.copyWith(idSolicitud: idSolicitud));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al crear la solicitud de rutina',
            style: AppTextStyles.subtittlesBold.copyWith(
              color: const Color(0xFFFFEDEB),
            ),
          ),
          backgroundColor: const Color(0xFF8B1A1A),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.all(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HEADER ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: AppRadius.md),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.onSurface.withValues(alpha: 0.10),
                ),
              ),
            ),
            child: Row(
              children: [
                // Ícono decorativo
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: const BorderRadius.all(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.assignment_add,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Nueva Solicitud de Rutina',
                    style: AppTextStyles.titleMd.copyWith(fontSize: 15),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: _isSaving ? null : widget.onCancelar,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.onSurfaceVariant,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          // ── BODY ────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo: Alumno
                const _FieldLabel('Alumno'),
                const SizedBox(height: AppSpacing.xs),
                AlumnoSelector(
                  alumnoRepository: widget.alumnoRepository,
                  alumnoSeleccionado: _selectedAlumno,
                  onAlumnoChanged: (alumno) =>
                      setState(() => _selectedAlumno = alumno),
                ),

                // Chip de alumno seleccionado
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: _selectedAlumno != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    AppRadius.full,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 12,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedAlumno!.nombreCompleto,
                                      style: AppTextStyles.labelCaps.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        letterSpacing: 0.02,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: AppSpacing.md),

                // Campo: Tipo de rutina
                const _FieldLabel('Tipo de rutina'),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 44,
                  child: TextFormField(
                    key: const Key('solicitud_rutina_name_field'),
                    controller: _nombreRutinaController,
                    style: AppTextStyles.subtittles.copyWith(fontSize: 13),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _guardarSolicitudRutina(),
                    decoration: InputDecoration(
                      hintText: 'Ej: Hipertrofia',
                      hintStyle: AppTextStyles.subtittles.copyWith(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 10, right: 6),
                        child: Icon(
                          Icons.fitness_center,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 0,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainer,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                // Micro-copy de ayuda
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Se usará como nombre sugerido al crear la rutina',
                  style: AppTextStyles.labelCaps.copyWith(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.02,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : widget.onCancelar,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.onSurfaceVariant,
                            side: const BorderSide(
                              color: AppColors.outlineVariant,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(AppRadius.md),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          key: const Key('guardar_solicitud_button'),
                          onPressed: _canSave ? _guardarSolicitudRutina : null,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.check, size: 16),
                          label: Text(
                            _isSaving ? 'Guardando' : 'Guardar',
                            style: AppTextStyles.buttonText.copyWith(
                              color: _canSave
                                  ? AppColors.onPrimary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            disabledBackgroundColor:
                                AppColors.surfaceContainerHigh,
                            disabledForegroundColor: AppColors.onSurfaceVariant,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(AppRadius.md),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Label de sección con acento izquierdo en lime primario.
class _FieldLabel extends StatelessWidget {
  final String text;
  final IconData? icon;

  const _FieldLabel(this.text, {this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(AppRadius.full),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppColors.onSurface),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: AppTextStyles.subtittlesBold.copyWith(
            fontSize: 13,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
