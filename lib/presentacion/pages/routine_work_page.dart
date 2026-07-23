import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/repositories/routine_repository.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/app_snackbar.dart';
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
  late RoutineBuilderController _routineController = RoutineBuilderController();
  late TextEditingController _notasController = TextEditingController();

  List<Ejercicio> _loadedExercises = [];
  Alumno? _alumnoSeleccionado;
  bool _isLoading = true;
  bool _isSaving = false;

  // Agregá esto junto a las otras variables de estado
  late TextEditingController _routineNameController = TextEditingController();

  @override
  void dispose() {
    _routineNameController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _routineController = RoutineBuilderController();
    _routineNameController = TextEditingController();
    _notasController = TextEditingController();

    // 👇 Precargar nombre y notas si hay rutina existente
    if (widget.rutinaExistente != null) {
      _routineNameController.text = widget.rutinaExistente!.nombre;
      _notasController.text = widget.rutinaExistente!.notasGenerales ?? '';
    }

    _loadData();
  }

  Future<void> _loadData() async {
    final exerciseRepo = ref.read(exerciseRepositoryProvider);
    final alumnoRepo = ref.read(alumnoRepositoryProvider);

    try {
      final exercises = await exerciseRepo.getExercises();

      // 👇 Precargar rutina existente en el controller
      if (widget.rutinaExistente != null) {
        final rutinaCompleta = await ref
            .read(routineRepositoryProvider)
            .getRutinaCompleta(widget.rutinaExistente!.idRutina!);
        if (rutinaCompleta != null) {
          _cargarRutinaEnController(rutinaCompleta);
          _notasController.text = widget.rutinaExistente!.notasGenerales ?? '';
        }

        // Preseleccionar alumno
        final alumno = await alumnoRepo.getAlumnoById(
          widget.rutinaExistente!.idAlumno!,
        );
        if (mounted) {
          setState(() {
            _loadedExercises = exercises;
            _alumnoSeleccionado = alumno;
            _isLoading = false;
          });
        }
      } else if (widget.solicitudOrigen != null) {
        final alumno = await alumnoRepo.getAlumnoById(
          widget.solicitudOrigen!.idAlumno!,
        );
        if (mounted) {
          setState(() {
            _loadedExercises = exercises;
            _alumnoSeleccionado = alumno;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadedExercises = exercises;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _cargarRutinaEnController(Rutina rutina) {
    for (var diaIndex = 0; diaIndex < rutina.dias.length; diaIndex++) {
      final dia = rutina.dias[diaIndex];

      _routineController.addDay(nombre: dia.nombre);
      _routineController.selectDay(diaIndex);

      for (
        var bloqueIndex = 0;
        bloqueIndex < dia.bloques.length;
        bloqueIndex++
      ) {
        final bloque = dia.bloques[bloqueIndex];

        _routineController.addBlock(nombre: bloque.nombre);
        _routineController.selectBlock(diaIndex, bloqueIndex);

        for (final ejercicioRutina in bloque.ejercicios) {
          final agregado = _routineController.addExercise(
            ejercicioRutina.ejercicio,
            blockIndex: bloqueIndex,
          );

          if (agregado) {
            final blockIdx = _routineController.bloques.length - 1;
            final exerciseIdx =
                _routineController.bloques[blockIdx].ejercicios.length - 1;

            for (
              var slotIndex = 0;
              slotIndex < ejercicioRutina.miembros.length;
              slotIndex++
            ) {
              final miembro = ejercicioRutina.miembros[slotIndex];
              _routineController.updateMemberParams(
                blockIndex: blockIdx,
                exerciseIndex: exerciseIdx,
                slotIndex: slotIndex,
                series: miembro.series,
                repeticiones: miembro.repeticiones,
                peso: miembro.peso,
              );
            }
          }
        }
      }
    }
  }

  Future<String> _savePDfInSupabase(Rutina rutina, int idRutina) async {
    final routineRepo = ref.read(routineRepositoryProvider);

    final pdfBytes = await PdfGenerator().generate(
      rutina: rutina.copyWith(idRutina: idRutina),
      alumno: _alumnoSeleccionado!,
    );
    final storageService = StorageService();
    final pdfUrl = await storageService.uploadPdf(
      bytes: pdfBytes,
      idRutina: idRutina,
      idAlumno: _alumnoSeleccionado!.idAlumno,
    );
    await routineRepo.updatePdfUrl(idRutina: idRutina, url: pdfUrl);

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

  Future<void> _deleteOldRoutines(RoutineRepository routineRepo) async {
    final storageService = StorageService();

    // 👇 Verificar si el alumno ya tiene 3 rutinas
    final rutinasAlumno = await routineRepo.getRutinasPorAlumno(
      _alumnoSeleccionado!.idAlumno,
    );

    // Si tiene 3, obtener la más antigua para borrar su PDF
    if (rutinasAlumno.length >= 3 && widget.rutinaExistente == null) {
      final masAntigua =
          rutinasAlumno.last; // ya vienen ordenadas por fecha desc
      if (masAntigua.rutina.urlPdf != null) {
        await storageService.deletePdf(
          idRutina: masAntigua.rutina.idRutina!,
          idAlumno: _alumnoSeleccionado!.idAlumno,
        );
      }
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
        idRutina: widget.rutinaExistente?.idRutina,
        notasGenerales: _notasController.text.isEmpty
            ? null
            : _notasController.text,
      );

      int idRutina;
      if (widget.rutinaExistente != null) {
        await routineRepo.updateRoutine(rutina);
        idRutina = widget.rutinaExistente!.idRutina!;
      } else {
        idRutina = await routineRepo.saveRoutine(rutina);
      }

      final pdfUrl = await _savePDfInSupabase(rutina, idRutina);
      await _sendRoutineViaMail(rutina, pdfUrl);

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
              widget.rutinaExistente != null
                  ? 'Rutina actualizada correctamente'
                  : 'Rutina guardada correctamente',
              style: AppTextStyles.subtittlesBold.copyWith(
                color: AppColors.successContent,
              ),
            ),
            backgroundColor: AppColors.successContainer,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(AppRadius.md),
            ),
          ),
        );
        context.pop((
          rutina: rutina.copyWith(idRutina: idRutina, urlPdf: pdfUrl),
          alumno: _alumnoSeleccionado!,
        ));
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Error al guardar: $e',
          type: SnackbarType.error,
          bottomMargin: 120,
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

  Future<void> _confirmarSalida(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
          side: BorderSide(color: AppColors.surfaceContainerHighest, width: 1),
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        titlePadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.all(AppRadius.md),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 22,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('¿Salir sin guardar?', style: AppTextStyles.titleMd),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perdés todos los cambios de la rutina actual. Esta acción no se puede deshacer.',
              style: AppTextStyles.subtittles.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(
              color: AppColors.surfaceContainerHighest,
              thickness: 1,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm + 2,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                        side: BorderSide(
                          color: AppColors.surfaceContainerHighest,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: AppTextStyles.subtittlesBold.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorContainer,
                      foregroundColor: AppColors.error,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm + 2,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      'Salir',
                      style: AppTextStyles.subtittlesBold.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
    );

    if (confirmar == true && context.mounted) {
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.success))
          : Stack(
              children: [
                Column(
                  children: [
                    // Barra superior
                    TopBar(
                      onMenuPressed: () => _confirmarSalida(context),
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
                                  color: Colors.white.withValues(alpha: 0.08),
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
                                  // Validación: debe haber día y bloque seleccionados
                                  final sinDia =
                                      _routineController.activeDayIndex == null;
                                  final sinBloque =
                                      !sinDia &&
                                      _routineController.activeBlockIndex ==
                                          null;

                                  if (sinDia || sinBloque) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).clearSnackBars();
                                    AppSnackbar.show(
                                      context,
                                      message: sinDia
                                          ? 'Seleccioná un día y un bloque antes de agregar un ejercicio.'
                                          : 'Seleccioná un bloque antes de agregar un ejercicio.',
                                      type: SnackbarType.warning,
                                      bottomMargin: 120,
                                    );
                                    return;
                                  }

                                  final agregado = _routineController
                                      .handleExerciseFromSidebar(ejercicio);
                                  if (!agregado && mounted) {
                                    AppSnackbar.show(
                                      context,
                                      message:
                                          'Ese ejercicio ya está en el bloque activo.',
                                      type: SnackbarType.warning,
                                      bottomMargin: 120,
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
                              notasController: _notasController,
                              onShowMessage: (msg) {
                                if (!mounted) return;
                                AppSnackbar.show(
                                  context,
                                  message: msg,
                                  type: SnackbarType.info,
                                  bottomMargin: 120,
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
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
