import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final String pageTitle;
  final List<Widget>? actionsCenter;
  final List<Widget>? actionsEnd;
  final bool isBack;
  final Key? menuBtnKey;

  const TopBar({
    super.key,
    required this.onMenuPressed,
    required this.pageTitle,
    this.actionsCenter,
    this.actionsEnd,
    this.isBack = false,
    this.menuBtnKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
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
                  key: menuBtnKey,
                  icon: Icon(
                    isBack ? Icons.arrow_back_ios_new : Icons.menu,
                    color: AppColors.onSurface,
                    size: isBack ? 18 : 22,
                  ),
                  onPressed: onMenuPressed,
                  splashRadius: 20,
                ),
                const SizedBox(width: AppSpacing.sm),

                const SizedBox(width: AppSpacing.sm),

                // Título de la página con subrayado primario
                Flexible(
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          pageTitle,
                          style: AppTextStyles.headlineLg,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.all(AppRadius.full),
                          ),
                        ),
                      ],
                    ),
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
