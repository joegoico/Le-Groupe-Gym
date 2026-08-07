import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/core/app_failure.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/inline_error.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/widget_muscular_groups.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';

class AddExerciseForm extends StatefulWidget {
  final List<CategoriaEjercicio> categorias;
  final VoidCallback onCancelar;
  final Function(Map<String, dynamic>) onGuardar;
  final ExerciseRepository exerciseRepository;

  const AddExerciseForm({
    super.key,
    required this.categorias,
    required this.onCancelar,
    required this.onGuardar,
    required this.exerciseRepository,
  });

  @override
  State<AddExerciseForm> createState() => _AddExerciseFormState();
}

class _AddExerciseFormState extends State<AddExerciseForm> {
  final TextEditingController _nombreController = TextEditingController();
  String? _selectedGroup;
  final Set<String> _selectedSubgroups = {};
  bool _isSaving = false;
  String? _errorEjercicio;

  bool get _canSave => !_isSaving && _nombreController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nombreController.addListener(_onNombreChanged);
  }

  void _onNombreChanged() {
    if (!mounted) return;
    setState(() => _errorEjercicio = null);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  List<int> getCategoriaIds() {
    final categoriasIds = <int>[];
    for (var categoria in widget.categorias) {
      if (_selectedGroup == categoria.nombre ||
          _selectedSubgroups.contains(categoria.nombre)) {
        categoriasIds.add(categoria.idCategoria);
      }
    }
    return categoriasIds;
  }

  Future<void> _guardarEjercicio() async {
    if (!_canSave) return;
    setState(() {
      _isSaving = true;
      _errorEjercicio = null;
    });
    final categoriaIds = getCategoriaIds();
    final localCategories = widget.categorias
        .where((c) => categoriaIds.contains(c.idCategoria))
        .toList();

    try {
      final nombreNormalizado = _nombreController.text.trim().toLowerCase();
      final ejerciciosExistentes = await widget.exerciseRepository
          .getExercises();
      final yaExiste = ejerciciosExistentes.any(
        (ejercicio) =>
            ejercicio.nombre.trim().toLowerCase() == nombreNormalizado,
      );
      if (yaExiste) {
        setState(
          () => _errorEjercicio = 'Ya existe un ejercicio con este nombre.',
        );
        return;
      }

      final id = await widget.exerciseRepository.createExercise(
        nombre: _nombreController.text.trim(),
        categoriaIds: categoriaIds,
      );

      final realExercise = Ejercicio(
        idEjercicio: id,
        nombre: _nombreController.text.trim(),
        categorias: localCategories,
      );

      widget.onGuardar({
        'ejercicio': realExercise,
        'categoriaIds': categoriaIds,
      });
    } on DuplicateFailure catch (_) {
      if (mounted) setState(() => _errorEjercicio = "Ya existe un ejercicio con este nombre.");
    } on AppFailure catch (e) {
      if (mounted) setState(() => _errorEjercicio = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _errorEjercicio = "No se pudo crear el ejercicio. Intentá nuevamente.");
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 480,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.all(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HEADER ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: AppRadius.md),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.onSurface.withValues(alpha: 0.10),
                ),
              ),
            ),
            child: Row(
              children: [
                // Ícono decorativo
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.all(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Registrar Nuevo Ejercicio',
                    style: AppTextStyles.titleMd.copyWith(fontSize: 15),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: _isSaving ? null : widget.onCancelar,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.onSurfaceVariant,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          // ── BODY ────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo: Nombre
                const _FieldLabel(
                  'Nombre del ejercicio',
                  icon: Icons.edit_outlined,
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 44,
                  child: TextField(
                    key: const Key('exercise_name_field'),
                    controller: _nombreController,
                    style: AppTextStyles.subtittles.copyWith(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ej. Press de Banca Inclinado',
                      hintStyle: AppTextStyles.subtittles.copyWith(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainer,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                if (_errorEjercicio != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  InlineError(
                    key: const Key('error-ejercicio'),
                    mensaje: _errorEjercicio!,
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                // Campo: Grupo muscular
                const _FieldLabel(
                  'Grupo muscular',
                  icon: Icons.accessibility_new,
                ),
                const SizedBox(height: AppSpacing.sm),
                MuscleCategorySelector(
                  // Solo pasamos grupos musculares: los subgrupos los maneja
                  // _MultiSubgrupoChips para soportar multi-selección.
                  categorias: widget.categorias
                      .where((c) => c.tipo == 'grupo_muscular')
                      .toList(),
                  selectedGroup: _selectedGroup,
                  selectedSubgroup: null,
                  onToggleGroup: (grupo) {
                    setState(() {
                      if (_selectedGroup == grupo) {
                        _selectedGroup = null;
                      } else {
                        _selectedGroup = grupo;
                      }
                      _selectedSubgroups.clear();
                    });
                  },
                  onToggleSubgroup: (_) {},
                ),
                // ── Chips de subgrupo (multi-selección) ──────────────────
                _MultiSubgrupoChips(
                  categorias: widget.categorias,
                  selectedGroup: _selectedGroup,
                  selectedSubgroups: _selectedSubgroups,
                  onToggle: (sub) => setState(() {
                    if (_selectedSubgroups.contains(sub)) {
                      _selectedSubgroups.remove(sub);
                    } else {
                      _selectedSubgroups.add(sub);
                    }
                  }),
                ),

                const SizedBox(height: AppSpacing.md),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : widget.onCancelar,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.onSurfaceVariant,
                            side: const BorderSide(
                              color: AppColors.outlineVariant,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(AppRadius.md),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _canSave ? _guardarEjercicio : null,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.check, size: 16),
                          label: Text(
                            _isSaving ? 'Guardando...' : 'Guardar Ejercicio',
                            style: AppTextStyles.buttonText.copyWith(
                              color: _canSave
                                  ? AppColors.onPrimary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            disabledBackgroundColor:
                                AppColors.surfaceContainerHigh,
                            disabledForegroundColor: AppColors.onSurfaceVariant,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(AppRadius.md),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Label de sección con acento izquierdo en lime primario.
class _FieldLabel extends StatelessWidget {
  final String text;
  final IconData? icon;

  const _FieldLabel(this.text, {this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(AppRadius.full),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppColors.onSurface),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: AppTextStyles.subtittlesBold.copyWith(
            fontSize: 13,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Chips de subgrupo con multi-selección, usados solo en el formulario
/// de creación de ejercicios (no en el filtro de la sidebar).
class _MultiSubgrupoChips extends StatelessWidget {
  final List<CategoriaEjercicio> categorias;
  final String? selectedGroup;
  final Set<String> selectedSubgroups;
  final void Function(String) onToggle;

  const _MultiSubgrupoChips({
    required this.categorias,
    required this.selectedGroup,
    required this.selectedSubgroups,
    required this.onToggle,
  });

  List<String> get _subgruposDisponibles {
    if (selectedGroup == null) return [];
    final idsPadre = categorias
        .where((c) => c.tipo == 'grupo_muscular' && c.nombre == selectedGroup)
        .map((c) => c.idCategoria)
        .toSet();
    return categorias
        .where(
          (c) => c.tipo == 'subgrupo' && idsPadre.contains(c.idCategoriaPadre),
        )
        .map((c) => c.nombre)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    final subgrupos = _subgruposDisponibles;
    if (subgrupos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Text(
              'SUBGRUPO',
              style: GoogleFonts.robotoMono(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '(seleccioná uno o más)',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: subgrupos.map((sub) {
            final isSelected = selectedSubgroups.contains(sub);
            return GestureDetector(
              key: Key(
                isSelected
                    ? 'subgrupo_chip_selected_$sub'
                    : 'subgrupo_chip_$sub',
              ),
              onTap: () => onToggle(sub),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.teal.withValues(alpha: 0.15)
                      : AppColors.surfaceContainer,
                  borderRadius: const BorderRadius.all(AppRadius.full),
                  border: Border.all(
                    color: isSelected
                        ? Colors.teal.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(Icons.check, size: 11, color: Colors.teal[300]),
                      const SizedBox(width: 4),
                    ],
                    Text(
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
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
