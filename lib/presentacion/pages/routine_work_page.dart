import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/alumno_model.dart';
import '../builder/exercise_sidebar.dart';
import '../builder/routine_builder_controller.dart';
import '../builder/routine_workspace.dart';
import '../builder/widgets/top_bar.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:le_groupe_gym/services/pdf_generator.dart';
import 'package:le_groupe_gym/services/service_storage.dart';
import 'package:le_groupe_gym/services/email_service.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:go_router/go_router.dart';

class MainPanelPage extends ConsumerStatefulWidget {
  final Rutina? rutinaExistente;
  final SolicitudRutina? solicitudOrigen;
  const MainPanelPage({super.key, this.rutinaExistente, this.solicitudOrigen});

  @override
  ConsumerState<MainPanelPage> createState() => _MainPanelPageState();
}

class _MainPanelPageState extends ConsumerState<MainPanelPage> {
  final RoutineBuilderController _routineController =
      RoutineBuilderController();

  List<Ejercicio> _loadedExercises = [];
  Alumno? _alumnoSeleccionado;
  bool _isLoading = true;
  bool _isSaving = false;

  // Agregá esto junto a las otras variables de estado
  final TextEditingController _routineNameController = TextEditingController();

  @override
  void dispose() {
    _routineNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final exerciseRepo = ref.read(exerciseRepositoryProvider);
    final alumnoRepo = ref.read(alumnoRepositoryProvider);

    try {
      final exercises = await exerciseRepo.getExercises();

      Alumno? alumnoPreseleccionado;

      // Si venimos desde el Dashboard de Solicitudes, cargamos al alumno
      // Si venimos desde el Dashboard de Solicitudes, cargamos al alumno
      if (widget.solicitudOrigen != null) {
        final alumnos = await alumnoRepo.getAlumnos();

        // Buscamos el índice de forma segura
        final index = alumnos.indexWhere(
          (a) => a.idAlumno == widget.solicitudOrigen!.idAlumno,
        );

        // Si lo encontramos, lo asignamos
        if (index != -1) {
          alumnoPreseleccionado = alumnos[index];
        }

        if (widget.solicitudOrigen!.notas != null) {
          _routineNameController.text = widget.solicitudOrigen!.notas!;
        }
      }

      setState(() {
        _loadedExercises = exercises;
        if (alumnoPreseleccionado != null) {
          _alumnoSeleccionado = alumnoPreseleccionado;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error al cargar datos: $e');
    }
  }

  Future<String> _savePDfInSupabase(Rutina nuevaRutina) async {
    final routineRepo = ref.read(routineRepositoryProvider);

    // Paso 1 — Guardar rutina y obtener id
    final idRutina = await routineRepo.saveRoutine(nuevaRutina);

    // Paso 2 — Generar PDF
    final pdfBytes = await PdfGenerator().generate(
      rutina: nuevaRutina.copyWith(idRutina: idRutina),
      alumno: _alumnoSeleccionado!,
    );

    // Paso 3 — Subir PDF a Storage
    final storageService = StorageService();
    final pdfUrl = await storageService.uploadPdf(
      bytes: pdfBytes,
      idRutina: idRutina,
      idAlumno: _alumnoSeleccionado!.idAlumno,
    );

    await routineRepo.updatePdfUrl(idRutina: idRutina, url: pdfUrl);

    debugPrint('PDF subido: $pdfUrl');
    return pdfUrl;
  }

  Future<void> _sendRoutineViaMail(Rutina nuevaRutina, String pdfUrl) async {
    if (_alumnoSeleccionado!.mail != null &&
        _alumnoSeleccionado!.mail!.isNotEmpty) {
      await EmailService().enviarRutina(
        pdfUrl: pdfUrl,
        mailAlumno: _alumnoSeleccionado!.mail!,
        nombreAlumno: _alumnoSeleccionado!.nombreCompleto,
        nombreRutina: nuevaRutina.nombre,
      );
    }
  }

  Future<void> _saveRoutine() async {
    if (_alumnoSeleccionado == null) return;
    setState(() => _isSaving = true);

    try {
      final routineRepo = ref.read(routineRepositoryProvider);
      final rutina = _routineController.buildRutina(
        nombre: _routineNameController.text.isEmpty
            ? 'Rutina sin nombre'
            : _routineNameController.text,
        idAlumno: _alumnoSeleccionado!.idAlumno,
      );

      final idRutina = await routineRepo.saveRoutine(rutina);
      final pdfUrl = await _savePDfInSupabase(rutina);
      await _sendRoutineViaMail(rutina, pdfUrl);

      // 👇 Eliminar solicitud si existe
      if (widget.solicitudOrigen != null) {
        final solicitudRepo = ref.read(solicitudRutinaRepositoryProvider);
        await solicitudRepo.deleteSolicitud(
          widget.solicitudOrigen!.idSolicitud!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rutina guardada correctamente',
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
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar: $e',
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
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _reloadExercises() async {
    final exerciseRepo = ref.read(exerciseRepositoryProvider);
    try {
      final exercises = await exerciseRepo.getExercises();
      setState(() => _loadedExercises = exercises);
    } catch (e) {
      debugPrint('Error al recargar ejercicios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    // Barra superior
                    TopBar(
                      onMenuPressed: () => context.pop(),
                      pageTitle: 'Crear Rutina',
                      isBack: true,
                      actionsCenter: [
                        SizedBox(
                          width: 220,
                          child: AlumnoSelector(
                            alumnoRepository: ref.read(
                              alumnoRepositoryProvider,
                            ),
                            alumnoSeleccionado: _alumnoSeleccionado,
                            onAlumnoChanged: (alumno) {
                              setState(() => _alumnoSeleccionado = alumno);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 220,
                          height: 44,
                          child: TextField(
                            key: const Key('routine_name_field'),
                            controller: _routineNameController,
                            style: AppTextStyles.titleMd,
                            decoration: InputDecoration(
                              hintText: 'Nombre de la rutina',
                              hintStyle: AppTextStyles.subtittles,
                              filled: true,
                              fillColor: AppColors.surfaceContainerHighest,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  AppRadius.md,
                                ),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  AppRadius.md,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      actionsEnd: [
                        SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: _alumnoSeleccionado != null
                                ? _saveRoutine
                                : null,
                            icon: const Icon(Icons.save_outlined, size: 17),
                            label: Text(
                              'Guardar Rutina',
                              style: AppTextStyles.buttonText,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              disabledBackgroundColor:
                                  AppColors.surfaceContainerHigh,
                              disabledForegroundColor:
                                  AppColors.onSurfaceVariant,
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(AppRadius.md),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 👇 Sidebar y Workspace en un Row con Expanded
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: ExcerciseSidebar(
                                allExercises: _loadedExercises,
                                controller: _routineController,
                                exerciseRepository: ref.read(
                                  exerciseRepositoryProvider,
                                ),
                                categoryExerciseRepository: ref.read(
                                  categoryExerciseRepositoryProvider,
                                ),
                                onAddExercise: (ejercicio) {
                                  final agregado = _routineController
                                      .handleExerciseFromSidebar(ejercicio);
                                  if (!agregado && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Ese ejercicio ya está en el bloque activo.',
                                          style: AppTextStyles.subtittlesBold.copyWith(
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        backgroundColor: AppColors.surfaceContainerHighest,
                                        behavior: SnackBarBehavior.floating,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(AppRadius.md),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onCreateEjercicio: _reloadExercises,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: RoutineWorkspace(
                              controller: _routineController,
                              onShowMessage: (msg) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      msg,
                                      style: AppTextStyles.subtittlesBold.copyWith(
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    backgroundColor: AppColors.surfaceContainerHighest,
                                    behavior: SnackBarBehavior.floating,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(AppRadius.md),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isSaving)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                  ),
              ],
            ),
    );
  }
}
