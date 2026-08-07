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
import 'package:le_groupe_gym/core/global_messenger.dart';
import 'package:le_groupe_gym/services/pdf_generator.dart';
import 'package:le_groupe_gym/services/service_storage.dart';
import 'package:le_groupe_gym/services/email_service.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/exit_routine_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/inline_error.dart';

class MainPanelPage extends ConsumerStatefulWidget {
  final Rutina? rutinaExistente;
  final SolicitudRutina? solicitudOrigen;
  final bool esPredeterminada;
  const MainPanelPage({
    super.key,
    this.rutinaExistente,
    this.solicitudOrigen,
    this.esPredeterminada = false,
  });

  @override
  ConsumerState<MainPanelPage> createState() => _MainPanelPageState();
}

class _MainPanelPageState extends ConsumerState<MainPanelPage> {
  late RoutineBuilderController _routineController = RoutineBuilderController();
  late TextEditingController _notasController = TextEditingController();

  List<Ejercicio> _loadedExercises = [];
  Alumno? _alumnoSeleccionado;
  bool _isLoading = true;
  final bool _isSaving = false;

  // Agregá esto junto a las otras variables de estado
  late TextEditingController _routineNameController = TextEditingController();
  String? _errorNombreRutina;

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

        // Preseleccionar alumno solo si no es predeterminada
        Alumno? alumno;
        if (!widget.esPredeterminada &&
            widget.rutinaExistente!.idAlumno != null) {
          alumno = await alumnoRepo.getAlumnoById(
            widget.rutinaExistente!.idAlumno!,
          );
        }

        if (mounted) {
          setState(() {
            _loadedExercises = exercises;
            if (alumno != null) {
              _alumnoSeleccionado = alumno;
            }
            _isLoading = false;
          });
        }
      } else if (widget.solicitudOrigen != null) {
        final alumno = await alumnoRepo.getAlumnoById(
          widget.solicitudOrigen!.idAlumno,
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

  Future<String> _savePDfInSupabase(
    Rutina rutina,
    int idRutina,
    RoutineRepository routineRepo,
  ) async {
    final pdfBytes = await PdfGenerator().generate(
      rutina: rutina.copyWith(idRutina: idRutina),
      alumno: widget.esPredeterminada ? null : _alumnoSeleccionado,
    );
    final storageService = StorageService();
    final pdfUrl = await storageService.uploadPdf(
      bytes: pdfBytes,
      idRutina: idRutina,
      nombreAlumno: widget.esPredeterminada
          ? 'genérica'
          : _alumnoSeleccionado!.nombreCompleto,
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
    if (widget.esPredeterminada) return;

    final storageService = StorageService();

    // 👇 Verificar si el alumno ya tiene 3 rutinas
    final rutinasAlumno = await routineRepo.getRutinasPorAlumno(
      _alumnoSeleccionado!.idAlumno,
    );

    if (rutinasAlumno.length >= 3 && widget.rutinaExistente == null) {
      final masAntigua = rutinasAlumno.last;

      if (masAntigua.rutina.urlPdf != null) {
        await storageService.deletePdf(urlPdf: masAntigua.rutina.urlPdf!);
      }
    }
  }

  void _saveRoutine() {
    if (!widget.esPredeterminada && _alumnoSeleccionado == null) return;

    final nombreIngresado = _routineNameController.text.trim();
    if (nombreIngresado.isEmpty) {
      setState(
        () => _errorNombreRutina = 'El nombre de la rutina es obligatorio',
      );
      return;
    }

    final rutinaLocal = _routineController.buildRutina(
      nombre: nombreIngresado,
      idAlumno: widget.esPredeterminada ? null : _alumnoSeleccionado!.idAlumno,
      idRutina:
          widget.rutinaExistente?.idRutina ??
          -DateTime.now().millisecondsSinceEpoch,
      notasGenerales: _notasController.text.isEmpty
          ? null
          : _notasController.text,
      esPredeterminada: widget.esPredeterminada,
    );

    final backgroundFuture = _saveRoutineBackground(
      rutinaLocal,
      widget.solicitudOrigen,
    );

    if (widget.esPredeterminada) {
      context.pop((rutinaLocal, backgroundFuture));
    } else {
      context.pop((
        rutina: rutinaLocal,
        alumno: _alumnoSeleccionado!,
        future: backgroundFuture,
      ));
    }
  }

  Future<Rutina> _saveRoutineBackground(
    Rutina rutina,
    SolicitudRutina? solicitudOrigen,
  ) async {
    try {
      final routineRepo = ref.read(routineRepositoryProvider);
      final solicitudRepo = ref.read(solicitudRutinaRepositoryProvider);

      // Damos 600ms para que la animación de "context.pop()" termine y el Dashboard
      // se dibuje por completo con la rutina temporal antes de empezar el trabajo pesado.
      // Esto previene que la app se congele a mitad de la animación en Flutter Web.
      await Future.delayed(const Duration(milliseconds: 600));

      await _deleteOldRoutines(routineRepo);

      int idRutina;
      if (widget.rutinaExistente != null) {
        await routineRepo.updateRoutine(rutina);
        idRutina = widget.rutinaExistente!.idRutina!;
      } else {
        idRutina = await routineRepo.saveRoutine(rutina);
      }

      final pdfUrl = await _savePDfInSupabase(rutina, idRutina, routineRepo);

      final finalRutina = rutina.copyWith(idRutina: idRutina, urlPdf: pdfUrl);

      if (!widget.esPredeterminada) {
        await _sendRoutineViaMail(finalRutina, pdfUrl);
      }

      if (solicitudOrigen != null) {
        await solicitudRepo.deleteSolicitud(solicitudOrigen.idSolicitud!);
      }

      GlobalMessenger.showSuccessSnackbar(
        widget.rutinaExistente != null
            ? 'Rutina actualizada correctamente'
            : 'Rutina guardada correctamente',
      );
      return finalRutina;
    } catch (e) {
      final msg = e.toString();
      final esUnicidad =
          msg.contains('unique') ||
          msg.contains('duplicate') ||
          msg.contains('23505') ||
          msg.contains('already exists');
      if (esUnicidad && widget.esPredeterminada) {
        GlobalMessenger.showErrorSnackbar(
          'Ya existe una rutina genérica con este nombre',
        );
      } else {
        GlobalMessenger.showErrorSnackbar(
          'Ocurrió un error inesperado al guardar la rutina. Verifica tu conexión e intenta de nuevo.',
        );
      }
      rethrow;
    }
  }

  void _onCreateEjercicio(Ejercicio realExercise, List<int> categoriaIds) {
    setState(() {
      _loadedExercises = [realExercise, ..._loadedExercises];
    });
    GlobalMessenger.showSuccessSnackbar(
      'El ejercicio fue creado correctamente',
    );
  }

  Future<void> _confirmarSalida(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => const ExitRoutineConfirmDialog(),
    );

    if (confirmar == true && context.mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/rutinas');
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
                      pageTitle: widget.rutinaExistente != null
                          ? 'Editar Rutina'
                          : widget.esPredeterminada
                          ? 'Nueva Rutina Predeterminada' // 👈
                          : 'Crear Rutina',
                      isBack: true,
                      actionsCenter: [
                        if (!widget.esPredeterminada)
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
                            onChanged: (_) {
                              if (_errorNombreRutina != null) {
                                setState(() => _errorNombreRutina = null);
                              }
                            },
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
                                  color: _errorNombreRutina != null
                                      ? Colors.redAccent
                                      : Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  AppRadius.md,
                                ),
                                borderSide: BorderSide(
                                  color: _errorNombreRutina != null
                                      ? Colors.redAccent
                                      : AppColors.primary,
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
                            onPressed:
                                (widget.esPredeterminada ||
                                    _alumnoSeleccionado != null)
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
                    if (_errorNombreRutina != null)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: InlineError(
                          key: const Key('error-nombre-rutina'),
                          mensaje: _errorNombreRutina!,
                        ),
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
                                onCreateEjercicio: _onCreateEjercicio,
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
