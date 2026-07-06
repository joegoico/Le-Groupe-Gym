import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/data/repositories/alumno_repository.dart';
import 'package:le_groupe_gym/data/repositories/solicitud_rutina_repository.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';

class AddSolicitudRutinaForm extends StatefulWidget {
  final VoidCallback onCancelar;
  final ValueChanged<SolicitudRutina> onGuardar;
  final AlumnoRepository alumnoRepository;
  final SolicitudRutinaRepository solicitudRutinaRepository;

  const AddSolicitudRutinaForm({
    super.key,
    required this.onCancelar,
    required this.onGuardar,
    required this.alumnoRepository,
    required this.solicitudRutinaRepository,
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
                  color: AppColors.onSurface.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Agregar Solicitud',
                    style: AppTextStyles.titleMd.copyWith(fontSize: 16),
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

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _FieldLabel('Alumno'),
                const SizedBox(height: AppSpacing.xs),
                AlumnoSelector(
                  alumnoRepository: widget.alumnoRepository,
                  alumnoSeleccionado: _selectedAlumno,
                  onAlumnoChanged: (alumno) =>
                      setState(() => _selectedAlumno = alumno),
                ),
                const SizedBox(height: AppSpacing.md),
                const _FieldLabel('Tipo de rutina'),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 44,
                  child: TextFormField(
                    key: const Key('solicitud_rutina_name_field'),
                    controller: _nombreRutinaController,
                    style: AppTextStyles.subtittles.copyWith(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Hipertrofia, Definición, Fuerza',
                      hintStyle: AppTextStyles.subtittles.copyWith(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
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
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : widget.onCancelar,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                          side: BorderSide(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(AppRadius.md),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelCaps.copyWith(
        fontSize: 11,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}
