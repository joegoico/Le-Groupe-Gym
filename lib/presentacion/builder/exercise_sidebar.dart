import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import '../../data/models/exercise_model.dart';
import 'routine_builder_controller.dart';
import 'sidebar_controller.dart';
import 'package:le_groupe_gym/presentacion/forms/exercise_form.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/widget_muscular_groups.dart';
import 'package:le_groupe_gym/data/repositories/category_exercise_repository.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';

class ExcerciseSidebar extends StatefulWidget {
  final List<Ejercicio> allExercises;
  final ValueChanged<Ejercicio> onAddExercise;
  final RoutineBuilderController controller;
  final VoidCallback? onCreateExercise;
  final ExerciseRepository exerciseRepository;
  final ICategoryExerciseRepository categoryExerciseRepository;
  final VoidCallback? onCreateEjercicio;

  const ExcerciseSidebar({
    super.key,
    required this.allExercises,
    required this.onAddExercise,
    required this.controller,
    this.onCreateExercise,
    required this.exerciseRepository,
    required this.categoryExerciseRepository,
    this.onCreateEjercicio,
  });

  @override
  State<ExcerciseSidebar> createState() => _ExcerciseSidebarState();
}

class _ExcerciseSidebarState extends State<ExcerciseSidebar> {
  late SidebarController _controller;
  List<CategoriaEjercicio> _categories = [];

  @override
  void initState() {
    super.initState();
    _controller = SidebarController(allExercises: widget.allExercises);
    _loadCategories();
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

  Future<void> _loadCategories() async {
    final categories = await widget.categoryExerciseRepository.getCategories();
    if (mounted) {
      setState(() => _categories = categories);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final filteredExercises = _controller.filteredExercises;
        final activeFiltersCount =
            _controller.selectedMuscleGroups.length +
            _controller.selectedSubgroups.length;

        return Container(
          width: 280,
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
                          color: AppColors.primary.withOpacity(0.15),
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
                        color: Colors.white.withOpacity(0.08),
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
                      .toList(), // 👈 deriva categorías desde los ejercicios
                  selectedGroups: _controller.selectedMuscleGroups,
                  selectedSubgroups: _controller.selectedSubgroups,
                  onToggleGroup: (grupo) =>
                      setState(() => _controller.toggleMuscleGroup(grupo)),
                  onToggleSubgroup: (sub) =>
                      setState(() => _controller.toggleSubgroup(sub)),
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
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: const BorderRadius.all(AppRadius.md),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
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
                          color: Colors.white.withOpacity(0.05),
                        ),
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
                            borderRadius: const BorderRadius.all(AppRadius.sm),
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
                          overflow: TextOverflow.ellipsis,
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
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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
                            widget.onCreateEjercicio?.call(); // 👈
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
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primary.withOpacity(0.5),
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
