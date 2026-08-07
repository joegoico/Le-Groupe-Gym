import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import '../../data/models/exercise_model.dart';
import 'routine_builder_controller.dart';
import '../controllers/sidebar_exercise_controller.dart';
import 'package:le_groupe_gym/presentacion/forms/exercise_form.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/widget_muscular_groups.dart';

class ExcerciseSidebar extends StatefulWidget {
  final List<Ejercicio> allExercises;
  final ValueChanged<Ejercicio> onAddExercise;
  final RoutineBuilderController controller;
  final VoidCallback? onCreateExercise;
  final ExerciseRepository exerciseRepository;
  final void Function(Ejercicio, List<int>)? onCreateEjercicio;

  const ExcerciseSidebar({
    super.key,
    required this.allExercises,
    required this.onAddExercise,
    required this.controller,
    this.onCreateExercise,
    required this.exerciseRepository,
    this.onCreateEjercicio,
  });

  @override
  State<ExcerciseSidebar> createState() => _ExcerciseSidebarState();
}

class _ExcerciseSidebarState extends State<ExcerciseSidebar> {
  late SidebarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SidebarController(allExercises: widget.allExercises);
  }

  @override
  void didUpdateWidget(ExcerciseSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allExercises != widget.allExercises) {
      setState(() {
        _controller = SidebarController(allExercises: widget.allExercises);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final filteredExercises = _controller.filteredExercises;
        final activeFiltersCount =
            (_controller.selectedMuscleGroup != null ? 1 : 0) +
            (_controller.selectedSubgroup != null ? 1 : 0);

        return Container(
          color: AppColors.surfaceLowest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CABECERA
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.onSurfaceVariant,
                      size: 14,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Librería',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    if (activeFiltersCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: const BorderRadius.all(AppRadius.full),
                        ),
                        child: Text(
                          '$activeFiltersCount',
                          style: GoogleFonts.robotoMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // BUSCADOR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextField(
                  onChanged: (value) {
                    setState(() => _controller.setSearchQuery(value));
                  },
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar ejercicios...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.onSurfaceVariant,
                      size: 18,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceContainer,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(AppRadius.md),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(AppRadius.md),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // FILTROS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: MuscleCategorySelector(
                  categorias: widget.allExercises
                      .expand((e) => e.categorias)
                      .toSet()
                      .toList(),
                  selectedGroup: _controller.selectedMuscleGroup,
                  selectedSubgroup: _controller.selectedSubgroup,
                  onToggleGroup: (grupo) {
                    setState(() => _controller.toggleMuscleGroup(grupo));
                  },
                  onToggleSubgroup: (sub) {
                    setState(() => _controller.toggleSubgroup(sub));
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Banner modo combinar
              if (widget.controller.isSelectingForCombine)
                Container(
                  margin: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.all(AppRadius.md),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.link,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.controller.combiningTargetExerciseName != null
                              ? 'Combinar con "${widget.controller.combiningTargetExerciseName}"'
                              : 'Tocá + en un ejercicio',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // CONTADOR
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Text(
                  '${filteredExercises.length} ejercicios encontrados',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),

              // LISTA
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    final categoria = exercise.categorias.isNotEmpty
                        ? exercise.categorias
                              .firstWhere(
                                (c) => c.tipo == 'grupo_muscular',
                                orElse: () => exercise.categorias.first,
                              )
                              .nombre
                        : '';

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: const BorderRadius.all(AppRadius.md),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: const BorderRadius.all(AppRadius.md),
                        child: InkWell(
                          onTap: () => widget.onAddExercise(exercise),
                          borderRadius: const BorderRadius.all(AppRadius.md),
                          hoverColor: AppColors.primary.withValues(alpha: 0.06),
                          highlightColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          splashColor: AppColors.primary.withValues(
                            alpha: 0.08,
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: const BorderRadius.all(
                                  AppRadius.sm,
                                ),
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ),
                            title: Text(
                              exercise.nombre,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurface,
                              ),
                            ),
                            subtitle: categoria.isNotEmpty
                                ? Text(
                                    categoria,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  )
                                : null,
                            trailing: IconButton(
                              icon: Icon(
                                widget.controller.isSelectingForCombine
                                    ? Icons.link
                                    : Icons.add,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              onPressed: () => widget.onAddExercise(exercise),
                              tooltip: widget.controller.isSelectingForCombine
                                  ? 'Combinar'
                                  : 'Agregar al bloque activo',
                              style: IconButton.styleFrom(
                                padding: const EdgeInsets.all(4),
                                minimumSize: const Size(28, 28),
                                hoverColor: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                highlightColor: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(AppRadius.sm),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // BOTÓN AGREGAR EJERCICIO
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => AddExerciseForm(
                          categorias: widget.allExercises
                              .expand((e) => e.categorias)
                              .toSet()
                              .toList(), // 👈 deriva categorías
                          exerciseRepository: widget.exerciseRepository,
                          onCancelar: () => Navigator.pop(context),
                          onGuardar: (data) {
                            Navigator.pop(context);
                            if (widget.onCreateEjercicio != null) {
                              widget.onCreateEjercicio!(
                                data['ejercicio'] as Ejercicio,
                                data['categoriaIds'] as List<int>,
                              );
                            }
                          },
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'Agregar ejercicio',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                      ),
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
