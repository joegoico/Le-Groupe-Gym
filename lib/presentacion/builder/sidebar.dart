import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/app_snackbar.dart';

class _SidebarItem {
  final String label;
  final IconData icon;
  final String route;
  final bool enabled;

  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    this.enabled = true,
  });
}

const _items = [
  _SidebarItem(
    label: 'Alumnos',
    icon: Icons.group_outlined,
    route: '/alumnos',
    enabled: false,
  ),
  _SidebarItem(
    label: 'Deudores',
    icon: Icons.account_balance_wallet_outlined,
    route: '/deudores',
    enabled: false,
  ),
  _SidebarItem(
    label: 'Gastos',
    icon: Icons.receipt_outlined,
    route: '/gastos',
    enabled: false,
  ),
  _SidebarItem(
    label: 'Precios',
    icon: Icons.sell_outlined,
    route: '/precios',
    enabled: false,
  ),
  _SidebarItem(
    label: 'Rutinas',
    icon: Icons.fitness_center_outlined,
    route: '/',
    enabled: true,
  ),
];

class Sidebar extends StatelessWidget {
  final String currentRoute;
  final bool isCollapsed;
  final VoidCallback onCerrarSesion;
  final Function(String) onNavigate;

  const Sidebar({
    super.key,
    required this.currentRoute,
    required this.isCollapsed,
    required this.onCerrarSesion,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 72 : 260,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        children: [
          // Logo y nombre
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            child: Row(
              children: [
                Image.asset('assets/logo.png', width: 28, height: 28),
                if (!isCollapsed) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Le Groupe Gym',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Divider(height: 1, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: AppSpacing.sm),

          // Items de navegación
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              children: _items.map((item) {
                final isActive = currentRoute == item.route;
                return _buildItem(context, item, isActive);
              }).toList(),
            ),
          ),

          Divider(height: 1, color: Colors.white.withOpacity(0.05)),

          // Cerrar sesión
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: _buildCerrarSesion(),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, _SidebarItem item, bool isActive) {
    return Opacity(
      opacity: item.enabled ? 1.0 : 0.35,
      child: InkWell(
        onTap: item.enabled
            ? () => onNavigate(item.route)
            : () => AppSnackbar.show(
                context,
                message: '"${item.label}" aún no está disponible.',
                type: SnackbarType.warning,
                bottomMargin: 24,
              ),
        borderRadius: const BorderRadius.all(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: const BorderRadius.all(AppRadius.md),
            border: isActive
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 22,
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.primary : AppColors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCerrarSesion() {
    if (isCollapsed) {
      return IconButton(
        onPressed: onCerrarSesion,
        tooltip: 'Cerrar sesión',
        icon: const Icon(
          Icons.logout_rounded,
          size: 20,
          color: AppColors.error,
        ),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onCerrarSesion,
      borderRadius: const BorderRadius.all(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: const BorderRadius.all(AppRadius.md),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Cerrar sesión',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
