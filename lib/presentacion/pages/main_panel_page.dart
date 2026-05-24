import 'package:flutter/material.dart';
import '../../data/models/exercise_model.dart';
import '../../data/repositories/exercise_repository.dart'; // Importamos el repositorio
import '../builder/widgets/exercise_sidebar.dart'; 
import '../builder/widgets/routine_builder_controller.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import '../builder/widgets/routine_workspace.dart'; 
import 'package:le_groupe_gym/data/repositories/routine_repository.dart'; // Importamos el repositorio de rutinas para el guardado

class MainPanelPage extends StatefulWidget {
  const MainPanelPage({super.key});

  @override
  State<MainPanelPage> createState() => _MainPanelPageState();
}

class _MainPanelPageState extends State<MainPanelPage> {
  final RoutineBuilderController _routineController = RoutineBuilderController();
  
  // 1. Instanciamos el contrato usando el Mock
  final ExerciseRepository _repository = MockExerciseRepository();
  final RoutineRepository _routineRepository = MockRoutineRepository();

  // 2. Variables para manejar el estado de la asincronía
  List<Ejercicio> _loadedExercises = [];
  bool _isLoading = true; // Arranca en true porque apenas abrimos la app, está cargando
  bool _isSaving = false; // Para manejar el estado de guardado de la rutina

  @override
  void initState() {
    super.initState();
    // 3. Disparamos la búsqueda a la base de datos apenas nace el widget
    _loadExercises();
  }

  // Función asíncrona para desenvolver el Future
  Future<void> _loadExercises() async {
    try {
      // Acá "abrimos" el Future. El código pausa acá hasta que el repo responda
      final exercises = await _repository.getExercises();
      
      // Una vez que llegan, actualizamos el estado para repintar la UI
      setState(() {
        _loadedExercises = exercises;
        _isLoading = false; // Apagamos el loader
      });
    } catch (e) {
      // Si falla la base de datos, apagamos el loader igual para no dejar clavado al usuario
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error al cargar la librería: $e');
    }
  }

  Future<void> _saveRoutine() async {
    final ejerciciosActuales = _routineController.currentRoutine;
    
    // Validamos por las dudas, aunque el botón debería estar deshabilitado
    if (ejerciciosActuales.isEmpty) return;

    setState(() => _isSaving = true);

    // Ensamblamos el objeto de negocio
    final nuevaRutina = Rutina(
      nombre: 'Rutina Personalizada (Desde Panel)', 
      ejercicios: ejerciciosActuales,
    );

    // Mostramos feedback al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guardando rutina en el sistema...'), duration: Duration(seconds: 1)),
    );

    try {
      final exito = await _routineRepository.saveRoutine(nuevaRutina);

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Rutina guardada con éxito!'), 
            backgroundColor: Colors.green,
          ),
        );
        // Limpiamos la pizarra para la siguiente
        _routineController.clearRoutine();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
              Row(
                children: [
                  ExcerciseSidebar(
                    allExercises: _loadedExercises,
                    onAddExercise: (ejercicio) {
                      setState(() {
                        _routineController.addExercise(ejercicio);
                      });
                    },
                  ),
                  Expanded(
                    child: RoutineWorkspace(
                      controller: _routineController,
                      onRefresh: () {
                        setState(() {}); 
                      },
                      onSave: _saveRoutine, // Conectamos el callback al método
                    ),
                  ),
                ],
              ),
              
              // Overlay semitransparente si está guardando
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