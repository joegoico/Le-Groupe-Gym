import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/widget_muscular_groups.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';

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
  String? _selectedSubgroup;

  bool get _canSave => _nombreController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nombreController.addListener(() => setState(() {}));
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
          _selectedSubgroup == categoria.nombre) {
        categoriasIds.add(categoria.idCategoria);
      }
    }
    return categoriasIds;
  }

  Future<void> _guardarEjercicio() async {
    final categoriaIds = getCategoriaIds();
    try {
      await widget.exerciseRepository.createExercise(
        nombre: _nombreController.text.trim(),
        categoriaIds: categoriaIds,
      );

      widget.onGuardar({
        'nombre': _nombreController.text.trim(),
        'grupos': _selectedGroup,
        'subgrupos': _selectedSubgroup,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El ejercicio fue creado correctamente',
            style: AppTextStyles.subtittlesBold.copyWith(
              color: const Color(0xFF0D1F00),
            ),
          ),
          backgroundColor: const Color(0xFF7ECC3B),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ocurrió el error $e',
            style: AppTextStyles.subtittlesBold.copyWith(
              color: const Color(0xFFFFEDEB),
            ),
          ),
          backgroundColor: const Color(0xFF8B1A1A),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Registrar Nuevo Ejercicio',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onCancelar,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // CONTENIDO
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    'Nombre del ejercicio',
                    style: GoogleFonts.robotoMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    key: const Key('exercise_name_field'),
                    controller: _nombreController,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ej. Press de Banca Inclinado',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.onSurfaceVariant.withOpacity(0.4),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainer,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
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
                  const SizedBox(height: AppSpacing.lg),

                  // Categorías
                  MuscleCategorySelector(
                    categorias: widget.categorias,
                    selectedGroup: _selectedGroup,
                    selectedSubgroup: _selectedSubgroup,
                    onToggleGroup: (grupo) {
                      setState(() {
                        if (_selectedGroup == grupo) {
                          _selectedGroup = null;
                          // limpiar subgrupos huérfanos
                          _selectedSubgroup = null;
                        } else {
                          _selectedGroup = grupo;
                        }
                      });
                    },
                    onToggleSubgroup: (sub) {
                      setState(() {
                        if (_selectedSubgroup == sub) {
                          _selectedSubgroup = null;
                        } else {
                          _selectedSubgroup = sub;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // FOOTER
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancelar,
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: _canSave ? _guardarEjercicio : null,
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(
                    'Guardar Ejercicio',
                    style: AppTextStyles.buttonText,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor: AppColors.surfaceContainerHigh,
                    disabledForegroundColor: AppColors.onSurfaceVariant,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.full),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
