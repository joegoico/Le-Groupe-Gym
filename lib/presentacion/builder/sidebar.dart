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
    enabled: true,
  ),
  _SidebarItem(
    label: 'Deudores',
    icon: Icons.account_balance_wallet_outlined,
    route: '/deudores',
    enabled: true,
  ),
  _SidebarItem(
    label: 'Ingresos',
    icon: Icons.payments_outlined,
    route: '/ingresos',
    enabled: true,
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
    enabled: true,
  ),
  _SidebarItem(
    label: 'Rutinas',
    icon: Icons.fitness_center_outlined,
    route: '/rutinas',
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
    return Container(
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
                      style: AppTextStyles.headlineLg.copyWith(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
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
                return _SidebarItemWidget(
                  item: item,
                  isActive: isActive,
                  isCollapsed: isCollapsed,
                  onNavigate: onNavigate,
                );
              }).toList(),
            ),
          ),

          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),

          // Cerrar sesión
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: _LogoutButtonWidget(
              isCollapsed: isCollapsed,
              onCerrarSesion: onCerrarSesion,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItemWidget extends StatefulWidget {
  final _SidebarItem item;
  final bool isActive;
  final bool isCollapsed;
  final Function(String) onNavigate;

  const _SidebarItemWidget({
    required this.item,
    required this.isActive,
    required this.isCollapsed,
    required this.onNavigate,
  });

  @override
  State<_SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<_SidebarItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.item.enabled ? 1.0 : 0.35,
      child: InkWell(
        onHover: (value) {
          if (widget.item.enabled) {
            setState(() => _isHovered = value);
          }
        },
        onTap: widget.item.enabled
            ? () => widget.onNavigate(widget.item.route)
            : () => AppSnackbar.show(
                context,
                message: '"${widget.item.label}" aún no está disponible.',
                type: SnackbarType.warning,
                bottomMargin: 24,
              ),
        borderRadius: const BorderRadius.all(AppRadius.md),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? AppSpacing.sm : AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primary.withValues(alpha: 0.15)
                : (_isHovered
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.transparent),
            borderRadius: const BorderRadius.all(AppRadius.md),
            border: widget.isActive
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: widget.isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                widget.item.icon,
                size: 22,
                color: widget.isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: widget.isActive
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: widget.isActive
                          ? AppColors.primary
                          : AppColors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.isActive)
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
}

class _LogoutButtonWidget extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onCerrarSesion;

  const _LogoutButtonWidget({
    required this.isCollapsed,
    required this.onCerrarSesion,
  });

  @override
  State<_LogoutButtonWidget> createState() => _LogoutButtonWidgetState();
}

class _LogoutButtonWidgetState extends State<_LogoutButtonWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isCollapsed) {
      return IconButton(
        onPressed: widget.onCerrarSesion,
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
      onHover: (value) => setState(() => _isHovered = value),
      onTap: widget.onCerrarSesion,
      borderRadius: const BorderRadius.all(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.error.withValues(alpha: 0.15)
              : AppColors.error.withValues(alpha: 0.08),
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
