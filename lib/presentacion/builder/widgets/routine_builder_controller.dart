import '../../../data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';

class RoutineBuilderController {
  // Estado privado para que la UI no pueda meterle mano directamente
  final List<EjercicioRutina> _currentRoutine = [];

  // Exponemos la lista como inmutable (read-only) hacia afuera
  List<EjercicioRutina> get currentRoutine => List.unmodifiable(_currentRoutine);

  // 1. Agregar ejercicio con valores por defecto
  void addExercise(Ejercicio ejercicio) {
    _currentRoutine.add(
      EjercicioRutina(
        ejercicio: ejercicio,
        series: 4,
        repeticiones: '10',
        descanso: '60',
        notas: '',
      ),
    );
  }

  // 2. Eliminar un ejercicio específico por su índice en la lista
  void removeExercise(int index) {
    if (index >= 0 && index < _currentRoutine.length) {
      _currentRoutine.removeAt(index);
    }
  }

  // 3. Limpiar toda la pizarra
  void clearRoutine() {
    _currentRoutine.clear();
  }

  // 4. Actualizar series o repeticiones de una tarjeta
  void updateExerciseParams({required int index, int? series, String? repeticiones}) {
    if (index >= 0 && index < _currentRoutine.length) {
      final item = _currentRoutine[index];
      if (series != null) item.series = series;
      if (repeticiones != null) item.repeticiones = repeticiones;
    }
  }
}