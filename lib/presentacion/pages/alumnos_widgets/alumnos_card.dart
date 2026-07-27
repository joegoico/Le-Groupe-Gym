import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
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
  final VoidCallback onVerPagos;

  const AlumnoCard({
    super.key,
    required this.alumno,
    required this.onEliminar,
    required this.onEditar,
    required this.onVerDetalles,
    required this.onVerPagos,
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
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.onSurfaceVariant,
                ),
                color: AppColors.surfaceContainerHigh,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(AppRadius.md),
                ),
                onSelected: (value) {
                  if (value == 'editar') onEditar();
                  if (value == 'eliminar') onEliminar();
                  if (value == 'detalles') onVerDetalles();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'editar',
                    child: Text(
                      'Editar',
                      style: GoogleFonts.inter(color: AppColors.onSurface),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Text(
                      'Eliminar',
                      style: GoogleFonts.inter(color: AppColors.error),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'detalles',
                    child: Text(
                      'Ver detalles',
                      style: GoogleFonts.inter(color: AppColors.onSurface),
                    ),
                  ),
                ],
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
          const SizedBox(height: AppSpacing.sm),
          // ── Acciones inferiores ───────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: Key('ver_pagos_${alumno.idAlumno}'),
              onPressed: onVerPagos,
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
              child: const Text('VER PAGOS'),
            ),
          ),
        ],
      ),
    );
  }
}
