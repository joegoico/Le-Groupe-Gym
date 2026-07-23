import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:le_groupe_gym/presentacion/forms/pago_form.dart';

// ── Paleta de colores para avatares (igual a alumnos_card) ──────────────────
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
    final a = alumno.apellido.isNotEmpty ? alumno.apellido[0].toUpperCase() : '';
    return '$n$a';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarColor = _avatarColor(alumno.nombre);
    final rutinasAsync = ref.watch(rutinasAlumnoProvider(alumno.idAlumno));
    final ultimoPagoAsync = ref.watch(ultimoPagoAlumnoProvider(alumno.idAlumno));

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
            icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                          color: alumno.aplicaDescuento ? AppColors.primary : AppColors.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        alumno.aplicaDescuento ? 'Con descuento' : 'Sin descuento',
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
              _buildCard(
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
                    _buildInfoRow(
                      Icons.mail_outline,
                      alumno.mail ?? 'Sin email registrado',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoRow(Icons.person_outline, alumno.nombreCompleto),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Estado de Cuenta Card
              _buildCard(
                accentLeft: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ESTADO DE CUENTA',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Próximo Venc.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Cuota al Día',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ],
                        ),
                        Text(
                          ultimoPago != null ? DateFormat('dd/MM/yyyy').format(ultimoPago.fechaDePago) : '-',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Divider(color: Colors.white.withValues(alpha: 0.05)),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Último pago: ${ultimoPago != null ? DateFormat('MM/yyyy').format(ultimoPago.fechaDePago) : 'N/A'}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          ultimoPago != null ? '\$${ultimoPago.monto.toInt()}' : '\$0',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Rutinas Asignadas Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RUTINAS ASIGNADAS',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.onSurfaceVariant),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    rutinasAsync.when(
                      data: (lista) {
                        if (lista.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            child: Text(
                              'No tiene rutinas asignadas',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: lista.map((item) {
                            final rutina = item.rutina;
                            final diasText = '${rutina.dias.length} días/semana';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: _buildRutinaTile(
                                icon: Icons.fitness_center,
                                title: rutina.nombre,
                                subtitle: diasText,
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Text(
                          'Error cargando rutinas: $err',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Botones de Acción Inferiores
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const Key('detalle_asignar_rutina_btn'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    'Asignar Nueva Rutina',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
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
                      ref.invalidate(ultimoPagoAlumnoProvider(alumno.idAlumno));
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
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

  Widget _buildCard({required Widget child, bool accentLeft = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.all(AppRadius.md),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(AppRadius.md),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (accentLeft)
                Container(
                  width: 4,
                  color: AppColors.primary,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
        const SizedBox(width: AppSpacing.md),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRutinaTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.all(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }
}
