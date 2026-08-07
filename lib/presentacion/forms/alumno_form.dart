import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/repositories/alumno_repository.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/inline_error.dart';
import 'package:uuid/uuid.dart';

class AlumnoForm extends StatefulWidget {
  /// Si es null, el formulario funciona en modo creación.
  final Alumno? alumno;
  final AlumnoRepository alumnoRepository;
  final ValueChanged<Alumno> onGuardar;
  final VoidCallback onCancelar;

  const AlumnoForm({
    super.key,
    this.alumno,
    required this.alumnoRepository,
    required this.onGuardar,
    required this.onCancelar,
  });

  @override
  State<AlumnoForm> createState() => _AlumnoFormState();
}

class _AlumnoFormState extends State<AlumnoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellidoCtrl;
  late final TextEditingController _mailCtrl;
  bool _isSaving = false;
  String? _errorAlumno;

  bool get _esEdicion => widget.alumno != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.alumno?.nombre ?? '');
    _apellidoCtrl = TextEditingController(text: widget.alumno?.apellido ?? '');
    _mailCtrl = TextEditingController(text: widget.alumno?.mail ?? '');
    _nombreCtrl.addListener(_clearError);
    _apellidoCtrl.addListener(_clearError);
  }

  void _clearError() {
    if (mounted && _errorAlumno != null) {
      setState(() => _errorAlumno = null);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _mailCtrl.dispose();
    super.dispose();
  }

  // ── Validaciones ────────────────────────────────────────────────────────────

  String? _validateNombre(String? v) {
    if (v == null || v.trim().isEmpty) return 'El nombre es requerido';
    if (v.trim().length < 2) return 'Mínimo 2 caracteres';
    return null;
  }

  String? _validateApellido(String? v) {
    if (v == null || v.trim().isEmpty) return 'El apellido es requerido';
    if (v.trim().length < 2) return 'Mínimo 2 caracteres';
    return null;
  }

  String? _validateMail(String? v) {
    if (v == null || v.trim().isEmpty) return null; // opcional
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(v.trim())) return 'Formato de email inválido';
    return null;
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    final id = _esEdicion ? widget.alumno!.idAlumno : const Uuid().v4();
    final alumno = Alumno(
      idAlumno: id,
      nombre: _nombreCtrl.text.trim(),
      apellido: _apellidoCtrl.text.trim(),
      mail: _mailCtrl.text.trim().isEmpty ? null : _mailCtrl.text.trim(),
    );

    setState(() {
      _isSaving = true;
      _errorAlumno = null;
    });

    try {
      final alumnos = await widget.alumnoRepository.getAlumnos(limit: 1000);
      final nombreNormalizado = alumno.nombre.toLowerCase();
      final apellidoNormalizado = alumno.apellido.toLowerCase();
      final yaExiste = alumnos.any(
        (existente) =>
            existente.idAlumno != alumno.idAlumno &&
            existente.nombre.trim().toLowerCase() == nombreNormalizado &&
            existente.apellido.trim().toLowerCase() == apellidoNormalizado,
      );
      if (yaExiste) {
        setState(
          () => _errorAlumno = 'Ya existe un alumno con ese nombre y apellido.',
        );
        return;
      }

      widget.onGuardar(alumno);
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorAlumno =
              'No se pudo verificar si el alumno ya existe. Intentá nuevamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 480,
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
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.all(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.person_add_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _esEdicion ? 'Editar Alumno' : 'Nuevo Alumno',
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Nombre + Apellido en fila ──────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel(
                              'Nombre',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            SizedBox(
                              height: 44,
                              child: TextFormField(
                                key: const Key('alumno_nombre_field'),
                                controller: _nombreCtrl,
                                validator: _validateNombre,
                                textInputAction: TextInputAction.next,
                                style: AppTextStyles.subtittles.copyWith(
                                  fontSize: 14,
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'Ej. Juan',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel(
                              'Apellido',
                              icon: Icons.badge_outlined,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            SizedBox(
                              height: 44,
                              child: TextFormField(
                                key: const Key('alumno_apellido_field'),
                                controller: _apellidoCtrl,
                                validator: _validateApellido,
                                textInputAction: TextInputAction.next,
                                style: AppTextStyles.subtittles.copyWith(
                                  fontSize: 14,
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'Ej. Pérez',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Mail ────────────────────────────────────────────────────
                  const _FieldLabel(
                    'Email (opcional)',
                    icon: Icons.mail_outline,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    height: 44,
                    child: TextFormField(
                      key: const Key('alumno_mail_field'),
                      controller: _mailCtrl,
                      validator: _validateMail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      style: AppTextStyles.subtittles.copyWith(fontSize: 14),
                      decoration: _inputDecoration(
                        hintText: 'Ej. juan@mail.com',
                      ),
                    ),
                  ),

                  if (_errorAlumno != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    InlineError(
                      key: const Key('error-alumno-duplicado'),
                      mensaje: _errorAlumno!,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  // ── Botones ──────────────────────────────────────────────────
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
                            key: const Key('alumno_guardar_button'),
                            onPressed: _isSaving ? null : _submit,
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
                              _isSaving
                                  ? 'Guardando...'
                                  : _esEdicion
                                  ? 'Guardar cambios'
                                  : 'Crear Alumno',
                              style: AppTextStyles.buttonText.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              disabledBackgroundColor:
                                  AppColors.surfaceContainerHigh,
                              disabledForegroundColor:
                                  AppColors.onSurfaceVariant,
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
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.subtittles.copyWith(
        fontSize: 14,
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      filled: true,
      fillColor: AppColors.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(AppRadius.md),
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(AppRadius.md),
        borderSide: BorderSide(color: AppColors.primary, width: 1),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(AppRadius.md),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(AppRadius.md),
        borderSide: BorderSide(color: AppColors.error),
      ),
    );
  }
}

// ── Label de campo con barra acento izquierda ────────────────────────────────

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
