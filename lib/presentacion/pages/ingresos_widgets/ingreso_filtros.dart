import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

/// Fila de campos de filtro de fecha para la pantalla de detalle.
/// La lógica de apertura de pickers y aplicación del filtro es del padre.
/// El filtro se aplica automáticamente al seleccionar una fecha.
class IngresoFiltros extends StatelessWidget {
  final String? fechaUnicaLabel;
  final String? rangoLabel;
  final bool hayFiltroActivo;
  final String? filtroDescripcion;
  final VoidCallback onTapFechaUnica;
  final VoidCallback onTapRango;
  final VoidCallback? onLimpiar;

  const IngresoFiltros({
    super.key,
    this.fechaUnicaLabel,
    this.rangoLabel,
    required this.hayFiltroActivo,
    this.filtroDescripcion,
    required this.onTapFechaUnica,
    required this.onTapRango,
    this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // — Campos de fecha —
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.only(
              topLeft: AppRadius.lg,
              topRight: AppRadius.lg,
              bottomLeft: hayFiltroActivo ? Radius.zero : AppRadius.lg,
              bottomRight: hayFiltroActivo ? Radius.zero : AppRadius.lg,
            ),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: _FechaField(
                  label: 'FECHA ÚNICA',
                  icon: Icons.calendar_today_outlined,
                  value: fechaUnicaLabel,
                  isActive: fechaUnicaLabel != null,
                  onTap: onTapFechaUnica,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FechaField(
                  label: 'RANGO DE FECHAS',
                  icon: Icons.date_range_outlined,
                  value: rangoLabel,
                  isActive: rangoLabel != null,
                  onTap: onTapRango,
                ),
              ),
            ],
          ),
        ),

        // — Indicador de filtro activo —
        if (hayFiltroActivo && filtroDescripcion != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: AppRadius.lg,
                bottomRight: AppRadius.lg,
              ),
              border: Border(
                left: BorderSide(color: AppColors.outlineVariant),
                right: BorderSide(color: AppColors.outlineVariant),
                bottom: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_alt_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Mostrando: $filtroDescripcion',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                if (onLimpiar != null)
                  InkWell(
                    onTap: onLimpiar,
                    borderRadius: const BorderRadius.all(AppRadius.full),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.close,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Limpiar',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FechaField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final bool isActive;
  final VoidCallback onTap;

  const _FechaField({
    required this.label,
    required this.icon,
    required this.value,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceContainerHigh,
          borderRadius: const BorderRadius.all(AppRadius.md),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelCaps.copyWith(
                      fontSize: 10,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value ?? 'Seleccionar...',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: value != null
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
