import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/alumno_selector.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final List<Alumno> alumnos;
  final Alumno? alumnoSeleccionado;
  final ValueChanged<Alumno?> onAlumnoChanged;
  final TextEditingController routineNameController;
  final VoidCallback? onGuardar;

  const TopBar({
    super.key,
    required this.onBack,
    required this.alumnos,
    required this.alumnoSeleccionado,
    required this.onAlumnoChanged,
    required this.routineNameController,
    this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Botón volver
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.onSurface,
              size: 16,
            ),
            onPressed: onBack,
            splashRadius: 20,
          ),
          const SizedBox(width: AppSpacing.sm),

          // Logo
          Image.asset('assets/logo.png', height: 28, width: 28),
          const SizedBox(width: AppSpacing.sm),

          // Nombre
          Text(
            'Le Groupe Gym',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),

          const Spacer(),

          // Selector alumno
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: AlumnoSelector(
                alumnos: alumnos,
                alumnoSeleccionado: alumnoSeleccionado,
                onAlumnoChanged: onAlumnoChanged,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Nombre rutina
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                key: const Key('routine_name_field'),
                controller: routineNameController,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Nombre de la rutina',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainer,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(AppRadius.md),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(AppRadius.md),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Botón guardar
          ElevatedButton.icon(
            onPressed: onGuardar,
            icon: const Icon(Icons.save_outlined, size: 15),
            label: Text(
              'Guardar Rutina',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor: AppColors.surfaceContainerHigh,
              disabledForegroundColor: AppColors.onSurfaceVariant,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(AppRadius.md),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
