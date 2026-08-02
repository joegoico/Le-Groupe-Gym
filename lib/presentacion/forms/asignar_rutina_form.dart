import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/repositories/alumno_repository.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';

class AsignarRutinaForm extends StatefulWidget {
  final VoidCallback onCancelar;
  final Function(Alumno, Rutina) onAsignar;
  final AlumnoRepository alumnoRepository;
  final List<Rutina> rutinasPredeterminadas;
  final Rutina rutinaSeleccionadaInicial;

  const AsignarRutinaForm({
    super.key,
    required this.onCancelar,
    required this.onAsignar,
    required this.alumnoRepository,
    required this.rutinasPredeterminadas,
    required this.rutinaSeleccionadaInicial,
  });

  @override
  State<AsignarRutinaForm> createState() => _AsignarRutinaFormState();
}

class _AsignarRutinaFormState extends State<AsignarRutinaForm> {
  Alumno? _selectedAlumno;
  late Rutina _selectedRutina;
  bool _isSaving = false;
  String? _errorMail;

  @override
  void initState() {
    super.initState();
    _selectedRutina = widget.rutinaSeleccionadaInicial;
  }

  void _validarYAsignar() {
    setState(() => _errorMail = null);

    if (_selectedAlumno == null) return;

    if (_selectedAlumno!.mail == null || _selectedAlumno!.mail!.trim().isEmpty) {
      setState(() {
        _errorMail = 'El alumno no tiene un correo electrónico asociado.';
      });
      return;
    }

    setState(() => _isSaving = true);
    widget.onAsignar(_selectedAlumno!, _selectedRutina);
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
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Asignar Rutina', style: AppTextStyles.titleMd),
                IconButton(
                  onPressed: widget.onCancelar,
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.onSurfaceVariant,
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),

          // ── FORMULARIO ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de Alumno
                Text('Alumno', style: AppTextStyles.labelCaps),
                const SizedBox(height: AppSpacing.xs),
                AlumnoSelector(
                  alumnoRepository: widget.alumnoRepository,
                  alumnoSeleccionado: _selectedAlumno,
                  onAlumnoChanged: (alumno) {
                    setState(() {
                      _selectedAlumno = alumno;
                      _errorMail = null; // Limpiar error al cambiar alumno
                    });
                  },
                ),
                if (_errorMail != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _errorMail!,
                    style: AppTextStyles.subtittles.copyWith(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                // Selector de Rutina Predeterminada
                Text('Rutina Predeterminada', style: AppTextStyles.labelCaps),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: const BorderRadius.all(AppRadius.md),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Rutina>(
                      value: _selectedRutina,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceContainerHigh,
                      style: AppTextStyles.subtittles,
                      items: widget.rutinasPredeterminadas.map((rutina) {
                        return DropdownMenuItem(
                          value: rutina,
                          child: Text(rutina.nombre),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedRutina = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── FOOTER ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(bottom: AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : widget.onCancelar,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: (_isSaving || _selectedAlumno == null)
                      ? null
                      : _validarYAsignar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.3,
                    ),
                    disabledForegroundColor: AppColors.onPrimary.withValues(
                      alpha: 0.3,
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.md),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text('Asignar', style: AppTextStyles.buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
