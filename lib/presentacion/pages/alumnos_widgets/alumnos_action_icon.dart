import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

class ActionIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  /// Si es true, el ícono se muestra en color rojo (destructivo) y el hover
  /// usa un fondo rojo translúcido — igual que los botones de eliminar del resto del app.
  final bool isDestructive;

  const ActionIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 20,
    this.isDestructive = false,
  });

  @override
  State<ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<ActionIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color idleColor = widget.isDestructive
        ? AppColors.error.withValues(alpha: 0.7)
        : AppColors.onSurfaceVariant;

    final Color hoverColor = widget.isDestructive
        ? AppColors.error
        : AppColors.onSurface;

    final Color bgHover = widget.isDestructive
        ? AppColors.error.withValues(alpha: 0.12)
        : AppColors.onSurfaceVariant.withValues(alpha: 0.12);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            // Sin fondo en reposo; fondo suave solo al hacer hover
            color: _hovered ? bgHover : Colors.transparent,
            borderRadius: const BorderRadius.all(AppRadius.sm),
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: _hovered ? hoverColor : idleColor,
          ),
        ),
      ),
    );
  }
}
