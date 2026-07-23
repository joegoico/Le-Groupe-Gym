import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/repositories/alumno_repository.dart';

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
  late bool _aplicaDescuento;
  bool _isLoading = false;

  bool get _esEdicion => widget.alumno != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.alumno?.nombre ?? '');
    _apellidoCtrl = TextEditingController(text: widget.alumno?.apellido ?? '');
    _mailCtrl = TextEditingController(text: widget.alumno?.mail ?? '');
    _aplicaDescuento = widget.alumno?.aplicaDescuento ?? false;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _mailCtrl.dispose();
    super.dispose();
  }

  // ── Validaciones ──────────────────────────────────────────────────────────

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

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final alumno = Alumno(
        idAlumno: widget.alumno?.idAlumno ?? '',
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
        mail: _mailCtrl.text.trim().isEmpty ? null : _mailCtrl.text.trim(),
        aplicaDescuento: _aplicaDescuento,
      );

      if (_esEdicion) {
        await widget.alumnoRepository.updateAlumno(alumno);
        widget.onGuardar(alumno);
      } else {
        final newId = await widget.alumnoRepository.createAlumno(alumno);
        widget.onGuardar(
          Alumno(
            idAlumno: newId,
            nombre: alumno.nombre,
            apellido: alumno.apellido,
            mail: alumno.mail,
            aplicaDescuento: alumno.aplicaDescuento,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.errorContainer,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 440,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ────────────────────────────────────────────────────
          _FormHeader(
            titulo: _esEdicion ? 'Editar Alumno' : 'Nuevo Alumno',
            onClose: widget.onCancelar,
          ),

          // ── Cuerpo ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nombre
                  _FieldLabel('Nombre'),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    key: const Key('alumno_nombre_field'),
                    controller: _nombreCtrl,
                    validator: _validateNombre,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(hintText: 'Ej. Juan'),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Apellido
                  _FieldLabel('Apellido'),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    key: const Key('alumno_apellido_field'),
                    controller: _apellidoCtrl,
                    validator: _validateApellido,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(hintText: 'Ej. Pérez'),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Mail (opcional)
                  _FieldLabel('Mail (opcional)'),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    key: const Key('alumno_mail_field'),
                    controller: _mailCtrl,
                    validator: _validateMail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: _inputDecoration(
                      hintText: 'Ej. juan@mail.com',
                      prefixIcon: Icons.mail_outline,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Switch — aplica descuento
                  _DescuentoSwitch(
                    value: _aplicaDescuento,
                    onChanged: (v) => setState(() => _aplicaDescuento = v),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Botones
                  _FormActions(
                    isLoading: _isLoading,
                    onCancelar: widget.onCancelar,
                    onGuardar: _submit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      filled: true,
      fillColor: AppColors.surfaceContainerHigh,
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(AppRadius.md),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(AppRadius.md),
        borderSide: BorderSide(color: AppColors.primaryDim),
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

// ── Widgets auxiliares ───────────────────────────────────────────────────────

class _FormHeader extends StatelessWidget {
  final String titulo;
  final VoidCallback onClose;

  const _FormHeader({required this.titulo, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: AppRadius.lg),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.all(AppRadius.sm),
            ),
            child: const Icon(
              Icons.person_add_outlined,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(titulo, style: AppTextStyles.subtittlesBold),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onClose,
            icon: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.labelCaps);
  }
}

class _DescuentoSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DescuentoSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: const BorderRadius.all(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aplica Descuento', style: AppTextStyles.subtittlesBold),
                const SizedBox(height: 2),
                Text(
                  'El alumno recibe un precio reducido',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            key: const Key('alumno_descuento_switch'),
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _FormActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancelar;
  final VoidCallback onGuardar;

  const _FormActions({
    required this.isLoading,
    required this.onCancelar,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : onCancelar,
          child: Text(
            'Cancelar',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ElevatedButton(
          key: const Key('alumno_guardar_button'),
          onPressed: isLoading ? null : onGuardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            disabledBackgroundColor: AppColors.surfaceContainerHigh,
            disabledForegroundColor: AppColors.onSurfaceVariant,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(AppRadius.md),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              : Text(
                  'Guardar',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
