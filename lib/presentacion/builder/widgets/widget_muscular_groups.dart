import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';

class MuscleCategorySelector extends StatelessWidget {
  final List<CategoriaEjercicio> categorias;
  final String? selectedGroup;
  final String? selectedSubgroup;
  final Function(String) onToggleGroup;
  final Function(String) onToggleSubgroup;

  const MuscleCategorySelector({
    super.key,
    required this.categorias,
    required this.selectedGroup,
    required this.selectedSubgroup,
    required this.onToggleGroup,
    required this.onToggleSubgroup,
  });

  List<String> get _grupos =>
      categorias
          .where((c) => c.tipo == 'grupo_muscular')
          .map((c) => c.nombre)
          .toSet()
          .toList()
        ..sort();

  // 👇 solo subgrupos de ejercicios que pertenecen al grupo seleccionado
  List<String> get _subgruposDisponibles {
    if (selectedGroup == null) return [];

    final idsPadresSeleccionados = categorias
        .where((c) => c.tipo == 'grupo_muscular' && selectedGroup == c.nombre)
        .map((c) => c.idCategoria)
        .toSet();

    return categorias
        .where(
          (c) =>
              c.tipo == 'subgrupo' &&
              idsPadresSeleccionados.contains(c.idCategoriaPadre),
        )
        .map((c) => c.nombre)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grupos musculares
        Text(
          'GRUPO MUSCULAR',
          style: GoogleFonts.robotoMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _grupos.map((grupo) {
            final isSelected = selectedGroup == grupo;
            return GestureDetector(
              onTap: () => onToggleGroup(grupo),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.surfaceContainer,
                  borderRadius: const BorderRadius.all(AppRadius.full),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  grupo,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Subgrupos
        if (_subgruposDisponibles.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'SUBGRUPO',
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _subgruposDisponibles.map((sub) {
              final isSelected = selectedSubgroup == sub;
              return GestureDetector(
                onTap: () => onToggleSubgroup(sub),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.teal.withValues(alpha: 0.12)
                        : AppColors.surfaceContainer,
                    borderRadius: const BorderRadius.all(AppRadius.full),
                    border: Border.all(
                      color: isSelected
                          ? Colors.teal.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    sub,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.teal[300]
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
