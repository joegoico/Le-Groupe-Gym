import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/presentacion/pages/alumnos_widgets/alumnos_action_icon.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Paleta de colores para avatares ─────────────────────────────────────────
const _avatarColors = [
  Color(0xFF5C6BC0), // índigo
  Color(0xFF26A69A), // teal
  Color(0xFFEF5350), // rojo
  Color(0xFF42A5F5), // azul
  Color(0xFFAB47BC), // púrpura
  Color(0xFF66BB6A), // verde
  Color(0xFFFFA726), // naranja
  Color(0xFF26C6DA), // cyan
];

Color _avatarColor(String nombre) =>
    _avatarColors[nombre.codeUnitAt(0) % _avatarColors.length];

class AlumnoCard extends StatelessWidget {
  final Alumno alumno;
  final VoidCallback onEliminar;
  final VoidCallback onEditar;
  final VoidCallback onVerDetalles;
  final VoidCallback onVerRutinas;

  const AlumnoCard({
    super.key,
    required this.alumno,
    required this.onEliminar,
    required this.onEditar,
    required this.onVerDetalles,
    required this.onVerRutinas,
  });

  @override
  Widget build(BuildContext context) {
    final initials =
        '${alumno.nombre.isNotEmpty ? alumno.nombre[0] : ''}${alumno.apellido.isNotEmpty ? alumno.apellido[0] : ''}'
            .toUpperCase();
    final avatarColor = _avatarColor(alumno.nombre);

    return Container(
      width: 180,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fila superior: avatar + acciones ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              ActionIcon(
                key: Key('eliminar_${alumno.idAlumno}'),
                icon: Icons.delete_outline,
                onTap: onEliminar,
                isDestructive: true,
              ),
              const SizedBox(width: 4),
              ActionIcon(
                key: Key('editar_${alumno.idAlumno}'),
                icon: Icons.edit_outlined,
                onTap: onEditar,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Nombre ────────────────────────────────────────────────────
          Text(
            alumno.nombreCompleto,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // ── Subtítulo ─────────────────────────────────────────────────
          Text(
            alumno.aplicaDescuento ? 'Con descuento' : 'Sin descuento',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: alumno.aplicaDescuento
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Acciones inferiores ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  key: Key('ver_detalles_${alumno.idAlumno}'),
                  onPressed: onVerDetalles,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.lg),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  child: const Text('VER DETALLES'),
                ),
              ),
              const SizedBox(width: 6),
              ActionIcon(
                key: Key('rutinas_${alumno.idAlumno}'),
                icon: Icons.fitness_center_outlined,
                onTap: onVerRutinas,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
