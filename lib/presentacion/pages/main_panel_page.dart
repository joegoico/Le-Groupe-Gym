import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/alumno_model.dart';
import '../builder/exercise_sidebar.dart';
import '../builder/routine_builder_controller.dart';
import '../builder/routine_workspace.dart';
import '../builder/top_bar.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:le_groupe_gym/services/pdf_generator.dart';
import 'package:le_groupe_gym/services/service_storage.dart';
import 'package:le_groupe_gym/services/email_service.dart';

class MainPanelPage extends ConsumerStatefulWidget {
  const MainPanelPage({super.key});

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
    try {
      final exercises = await exerciseRepo.getExercises();
      setState(() {
        _loadedExercises = exercises;
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
    if (_routineController.isEmpty || _alumnoSeleccionado == null) return;

    setState(() => _isSaving = true);

    final nombreRutina = _routineNameController.text.trim().isEmpty
        ? 'Rutina de ${_alumnoSeleccionado!.nombreCompleto}'
        : _routineNameController.text.trim();

    final nuevaRutina = _routineController.buildRutina(
      nombre: nombreRutina,
      idAlumno: _alumnoSeleccionado!.idAlumno,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Guardando rutina en el sistema...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final String url = await _savePDfInSupabase(nuevaRutina);

      await _sendRoutineViaMail(nuevaRutina, url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Rutina guardada y PDF generado!'),
            backgroundColor: Colors.green,
          ),
        );
        _routineController.clearRoutine();
        _routineNameController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
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
                      onBack:
                          () {}, // por ahora vacío — se conecta cuando haya navegación
                      alumnoRepository: ref.read(alumnoRepositoryProvider),
                      alumnoSeleccionado: _alumnoSeleccionado,
                      onAlumnoChanged: (alumno) {
                        setState(() => _alumnoSeleccionado = alumno);
                      },
                      routineNameController: _routineNameController,
                      onGuardar: _alumnoSeleccionado != null
                          ? _saveRoutine
                          : null,
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
                                      const SnackBar(
                                        content: Text(
                                          'Ese ejercicio ya está en el bloque activo.',
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
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(msg)));
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
