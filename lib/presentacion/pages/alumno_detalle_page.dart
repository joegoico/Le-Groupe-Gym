import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:le_groupe_gym/providers/alumno_view_providers.dart';
import 'package:le_groupe_gym/presentacion/forms/pago_form.dart';
import 'package:le_groupe_gym/presentacion/pages/detalle_widgets/detalle_card.dart';
import 'package:le_groupe_gym/presentacion/pages/detalle_widgets/detalle_info_row.dart';
import 'package:le_groupe_gym/presentacion/pages/detalle_widgets/estado_cuenta_card.dart';
import 'package:le_groupe_gym/presentacion/pages/detalle_widgets/rutinas_asignadas_card.dart';

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

class AlumnoDetallePage extends ConsumerWidget {
  final Alumno alumno;

  const AlumnoDetallePage({super.key, required this.alumno});

  String _getInitials() {
    final n = alumno.nombre.isNotEmpty ? alumno.nombre[0].toUpperCase() : '';
    final a = alumno.apellido.isNotEmpty
        ? alumno.apellido[0].toUpperCase()
        : '';
    return '$n$a';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarColor = _avatarColor(alumno.nombre);
    final rutinasAsync = ref.watch(rutinasAlumnoProvider(alumno.idAlumno));
    final ultimoPagoAsync = ref.watch(
      ultimoPagoAlumnoProvider(alumno.idAlumno),
    );

    final ultimoPago = ultimoPagoAsync.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          key: const Key('detalle_back_btn'),
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(
          'Detalle de Alumno',
          style: AppTextStyles.titleMd.copyWith(
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 46,
                  backgroundColor: avatarColor,
                  child: Text(
                    _getInitials(),
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Nombre
                Text(
                  alumno.nombreCompleto,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),

                // Descuento Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: alumno.aplicaDescuento
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          alumno.aplicaDescuento
                              ? 'Con descuento'
                              : 'Sin descuento',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Información Personal Card
                DetalleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INFORMACIÓN PERSONAL',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      DetalleInfoRow(
                        icon: Icons.mail_outline,
                        text: alumno.mail ?? 'Sin email registrado',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DetalleInfoRow(
                        icon: Icons.person_outline,
                        text: alumno.nombreCompleto,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Estado de Cuenta Card
                EstadoCuentaCard(ultimoPago: ultimoPago),
                const SizedBox(height: AppSpacing.lg),

                // Rutinas Asignadas Card
                RutinasAsignadasCard(rutinasAsync: rutinasAsync),
                const SizedBox(height: AppSpacing.xl),

                // Botones de Acción Inferior
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    key: const Key('detalle_registrar_pago_btn'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => PagoForm(alumno: alumno),
                      ).then((_) {
                        ref.invalidate(
                          ultimoPagoAlumnoProvider(alumno.idAlumno),
                        );
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      'Registrar Pago',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
