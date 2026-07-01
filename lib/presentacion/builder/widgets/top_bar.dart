import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final String pageTitle;
  final List<Widget>? actionsCenter;
  final List<Widget>? actionsEnd;

  const TopBar({
    super.key,
    required this.onMenuPressed,
    required this.pageTitle,
    this.actionsCenter,
    this.actionsEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Botón menú
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: AppColors.onSurface,
                    size: 22,
                  ),
                  onPressed: onMenuPressed,
                  splashRadius: 20,
                ),
                const SizedBox(width: AppSpacing.sm),

                // Logo
                Image.asset('assets/logo.png', height: 28, width: 28),
                const SizedBox(width: AppSpacing.sm),

                // Nombre gimnasio
                Text(
                  'Le Groupe Gym',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                // Título de la página
                Flexible(
                  child: Text(
                    pageTitle,
                    style: AppTextStyles.titleMd,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Centro — selector alumno, nombre rutina, etc.
          if (actionsCenter != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actionsCenter!
                  .map(
                    (action) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: action,
                    ),
                  )
                  .toList(),
            ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actionsEnd != null
                  ? actionsEnd!
                        .map(
                          (action) => Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: action,
                            ),
                          ),
                        )
                        .toList()
                  : [],
            ),
          ),
        ],
      ),
    );
  }
}
