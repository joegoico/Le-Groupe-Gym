import 'package:flutter/foundation.dart';
import 'package:le_groupe_gym/data/models/dia_rutina_model.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';

class RoutineBuilderController extends ChangeNotifier {
  final List<DiaRutina> _dias = [];
  int? _activeDayIndex;
  int? _activeBlockIndex;
  int? _combiningBlockIndex;
  int? _combiningExerciseIndex;
  int _pendingCombineSeries = 4;
  String _pendingCombineReps = '10';
  int _blockIdCounter = 0;

  // ── Getters de días ──────────────────────────────────────────────
  List<DiaRutina> get dias => List.unmodifiable(_dias);
  int? get activeDayIndex => _activeDayIndex;

  // ── Getters de bloques (del día activo) ──────────────────────────
  List<BloqueRutina> get bloques {
    final dia = _diaActivo;
    if (dia == null) return [];
    return List.unmodifiable(dia.bloques);
  }

  int? get activeBlockIndex => _activeBlockIndex;

  List<EjercicioRutina> get currentRoutine =>
      _dias.expand((d) => d.bloques.expand((b) => b.ejercicios)).toList();

  int get totalEjercicios => currentRoutine.length;

  bool get isEmpty => _dias.isEmpty || totalEjercicios == 0;

  // ── Combining ────────────────────────────────────────────────────
  int? get combiningBlockIndex => _combiningBlockIndex;
  int? get combiningExerciseIndex => _combiningExerciseIndex;
  int get pendingCombineSeries => _pendingCombineSeries;
  String get pendingCombineReps => _pendingCombineReps;
  bool get isSelectingForCombine => _combiningBlockIndex != null;

  String? get combiningTargetExerciseName {
    if (_combiningBlockIndex == null || _combiningExerciseIndex == null)
      return null;
    final dia = _diaActivo;
    if (dia == null) return null;
    return dia
        .bloques[_combiningBlockIndex!]
        .ejercicios[_combiningExerciseIndex!]
        .ejercicio
        .nombre;
  }

  bool isCombiningAt(int blockIndex, int exerciseIndex) =>
      _combiningBlockIndex == blockIndex &&
      _combiningExerciseIndex == exerciseIndex;

  // ── Día activo ───────────────────────────────────────────────────
  DiaRutina? get _diaActivo {
    if (_activeDayIndex == null || _dias.isEmpty) return null;
    if (_activeDayIndex! >= _dias.length) return null;
    return _dias[_activeDayIndex!];
  }

  int addDay({String? nombre}) {
    if (_dias.length >= 5) return -1;
    final dia = DiaRutina(
      nombre: nombre ?? 'Día ${_dias.length + 1}',
      orden: _dias.length,
    );
    _dias.add(dia);
    _activeDayIndex = _dias.length - 1;
    _activeBlockIndex = null;
    notifyListeners();
    return _activeDayIndex!;
  }

  bool removeDay(int dayIndex) {
    if (_dias.length <= 1) return false;
    if (dayIndex < 0 || dayIndex >= _dias.length) return false;
    _dias.removeAt(dayIndex);
    _syncIndicesAfterDayRemoved(dayIndex);
    notifyListeners();
    return true;
  }

  void renameDay(int dayIndex, String nombre) {
    if (dayIndex < 0 || dayIndex >= _dias.length) return;
    _dias[dayIndex] = _dias[dayIndex].copyWith(nombre: nombre);
    notifyListeners();
  }

  void selectDay(int dayIndex) {
    if (dayIndex >= 0 && dayIndex < _dias.length) {
      _activeDayIndex = dayIndex;
      _activeBlockIndex = null;
      notifyListeners();
    }
  }

  void deselectDay() {
    _activeDayIndex = null;
    _activeBlockIndex = null;
    cancelCombining();
    notifyListeners();
  }

  // ── Métodos de bloques ───────────────────────────────────────────
  int addBlock({String? nombre}) {
    // Si no hay días, crear uno automáticamente
    if (_dias.isEmpty) addDay();

    _blockIdCounter++;
    final bloque = BloqueRutina(
      id: 'bloque-$_blockIdCounter',
      nombre: nombre ?? 'Bloque ${_diaActivo!.bloques.length + 1}',
    );
    _diaActivo!.bloques.add(bloque);
    _activeBlockIndex = _diaActivo!.bloques.length - 1;
    notifyListeners();
    return _activeBlockIndex!;
  }

  void selectBlock(int dayIndex, int blockIndex) {
    if (dayIndex < 0 || dayIndex >= _dias.length) return;
    final dia = _dias[dayIndex];
    if (blockIndex >= 0 && blockIndex < dia.bloques.length) {
      _activeDayIndex = dayIndex;
      _activeBlockIndex = blockIndex;
    }
    notifyListeners();
  }

  bool removeBlock(int blockIndex) {
    final dia = _diaActivo;
    if (dia == null) return false;
    if (blockIndex < 0 || blockIndex >= dia.bloques.length) return false;
    if (dia.bloques.length <= 1) return false;

    dia.bloques.removeAt(blockIndex);
    _syncIndicesAfterBlockRemoved(blockIndex);
    notifyListeners();
    return true;
  }

  // ── Métodos de ejercicios ────────────────────────────────────────
  bool addExercise(Ejercicio ejercicio, {int? blockIndex}) {
    if (_dias.isEmpty) addDay();

    final target = _resolveBlockIndex(blockIndex);
    if (target == null) {
      addBlock();
      return addExercise(ejercicio, blockIndex: _diaActivo!.bloques.length - 1);
    }

    // Verificar duplicado en TODA la rutina
    final yaExiste = _dias.any(
      (d) => d.bloques.any(
        (b) => b.ejercicios.any(
          (e) => e.ejercicio.idEjercicio == ejercicio.idEjercicio,
        ),
      ),
    );
    if (yaExiste) return false;

    _diaActivo!.bloques[target].ejercicios.add(
      EjercicioRutina(
        ejercicio: ejercicio,
        series: 4,
        repeticiones: '10',
        peso: '',
        notas: '',
      ),
    );
    _activeBlockIndex = target;
    notifyListeners();
    return true;
  }

  bool handleExerciseFromSidebar(Ejercicio ejercicio) {
    if (_combiningBlockIndex != null && _combiningExerciseIndex != null) {
      return _combineFromSidebar(ejercicio);
    }
    return addExercise(ejercicio);
  }

  bool _combineFromSidebar(Ejercicio ejercicio) {
    final blockIndex = _combiningBlockIndex!;
    final exerciseIndex = _combiningExerciseIndex!;
    if (_ejercicioYaEnTarjeta(blockIndex, exerciseIndex, ejercicio))
      return false;
    confirmCombine(
      blockIndex: blockIndex,
      exerciseIndex: exerciseIndex,
      ejercicio: ejercicio,
      series: _pendingCombineSeries,
      repeticiones: _pendingCombineReps,
    );
    return true;
  }

  bool _ejercicioYaEnTarjeta(
    int blockIndex,
    int exerciseIndex,
    Ejercicio ejercicio,
  ) {
    final dia = _diaActivo;
    if (dia == null) return false;
    return dia.bloques[blockIndex].ejercicios[exerciseIndex].miembros.any(
      (m) => m.ejercicio.idEjercicio == ejercicio.idEjercicio,
    );
  }

  bool removeExercise(int blockIndex, int exerciseIndex) {
    final dia = _diaActivo;
    if (dia == null) return false;
    if (!_isValidExerciseIndex(blockIndex, exerciseIndex)) return false;
    if (dia.bloques[blockIndex].ejercicios.length <= 1) return false;
    dia.bloques[blockIndex].ejercicios.removeAt(exerciseIndex);
    _syncIndicesAfterExerciseRemoved(blockIndex, exerciseIndex);
    notifyListeners();
    return true;
  }

  bool moveExercise({
    required int fromBlockIndex,
    required int fromExerciseIndex,
    required int toBlockIndex,
    int? toExerciseIndex,
  }) {
    final dia = _diaActivo;
    if (dia == null) return false;
    if (!_isValidExerciseIndex(fromBlockIndex, fromExerciseIndex)) return false;
    if (toBlockIndex < 0 || toBlockIndex >= dia.bloques.length) return false;
    if (fromBlockIndex == toBlockIndex) return false;

    final source = dia.bloques[fromBlockIndex];
    if (source.ejercicios.length <= 1) return false;

    final tarjeta = source.ejercicios.removeAt(fromExerciseIndex);
    final destino = dia.bloques[toBlockIndex];
    final insertAt = toExerciseIndex == null
        ? destino.ejercicios.length
        : toExerciseIndex.clamp(0, destino.ejercicios.length);
    destino.ejercicios.insert(insertAt, tarjeta);

    _syncIndicesAfterExerciseRemoved(fromBlockIndex, fromExerciseIndex);
    _activeBlockIndex = toBlockIndex;
    notifyListeners();
    return true;
  }

  void clearRoutine() {
    _dias.clear();
    _activeDayIndex = null;
    _activeBlockIndex = null;
    _combiningBlockIndex = null;
    _combiningExerciseIndex = null;
    _resetPendingCombineParams();
    notifyListeners();
  }

  void updateMemberParams({
    required int blockIndex,
    required int exerciseIndex,
    required int slotIndex,
    int? series,
    String? repeticiones,
    String? notas,
    String? peso,
  }) {
    if (!_isValidExerciseIndex(blockIndex, exerciseIndex)) return;
    _diaActivo!.bloques[blockIndex].ejercicios[exerciseIndex].actualizarMiembro(
      slotIndex,
      series: series,
      repeticiones: repeticiones,
      notas: notas,
      peso: peso,
    );
  }

  void updateExerciseParams({
    required int blockIndex,
    required int exerciseIndex,
    int? series,
    String? repeticiones,
  }) {
    updateMemberParams(
      blockIndex: blockIndex,
      exerciseIndex: exerciseIndex,
      slotIndex: 0,
      series: series,
      repeticiones: repeticiones,
    );
  }

  void updatePendingCombineParams({int? series, String? repeticiones}) {
    if (_combiningBlockIndex == null) return;
    if (series != null) _pendingCombineSeries = series;
    if (repeticiones != null) _pendingCombineReps = repeticiones;
  }

  void startCombining(int blockIndex, int exerciseIndex) {
    if (!_isValidExerciseIndex(blockIndex, exerciseIndex)) return;
    final dia = _diaActivo;
    if (dia == null) return;
    if (dia.bloques[blockIndex].ejercicios[exerciseIndex].esSuperserie) return;
    _combiningBlockIndex = blockIndex;
    _combiningExerciseIndex = exerciseIndex;
    _resetPendingCombineParams();
    notifyListeners();
  }

  void cancelCombining() {
    _combiningBlockIndex = null;
    _combiningExerciseIndex = null;
    _resetPendingCombineParams();
    notifyListeners();
  }

  void confirmCombine({
    required int blockIndex,
    required int exerciseIndex,
    required Ejercicio ejercicio,
    int series = 4,
    String repeticiones = '10',
  }) {
    if (!_isValidExerciseIndex(blockIndex, exerciseIndex)) return;
    _diaActivo!.bloques[blockIndex].ejercicios[exerciseIndex].combinarCon(
      ejercicio,
      series: series,
      repeticiones: repeticiones,
    );
    if (_combiningBlockIndex == blockIndex &&
        _combiningExerciseIndex == exerciseIndex) {
      cancelCombining();
    }
    notifyListeners();
  }

  bool uncombineExercise(int blockIndex, int exerciseIndex) {
    final dia = _diaActivo;
    if (dia == null) return false;
    if (!_isValidExerciseIndex(blockIndex, exerciseIndex)) return false;
    final tarjeta = dia.bloques[blockIndex].ejercicios[exerciseIndex];
    if (!tarjeta.esSuperserie) return false;

    tarjeta.deshacerCombinacion();
    notifyListeners();
    return true;
  }

  void reorderExerciseInBlock(int blockIndex, int oldIndex, int newIndex) {
    final dia = _diaActivo;
    if (dia == null) return;
    if (blockIndex < 0 || blockIndex >= dia.bloques.length) return;
    final lista = dia.bloques[blockIndex].ejercicios;
    if (oldIndex < 0 || oldIndex >= lista.length) return;
    if (newIndex > oldIndex) newIndex -= 1;
    if (newIndex < 0 || newIndex >= lista.length) return;
    final item = lista.removeAt(oldIndex);
    lista.insert(newIndex, item);
    notifyListeners();
  }

  void renameBlock(int blockIndex, String nombre) {
    final dia = _diaActivo;
    if (dia == null) return;
    if (blockIndex >= 0 && blockIndex < dia.bloques.length) {
      dia.bloques[blockIndex].nombre = nombre;
    }
    notifyListeners();
  }

  Rutina buildRutina({
    required String nombre,
    String? idAlumno,
    int? idRutina,
  }) {
    return Rutina(
      idRutina: idRutina,
      idAlumno: idAlumno,
      nombre: nombre,
      dias: _dias
          .map(
            (d) => DiaRutina(
              idDia: d.idDia,
              nombre: d.nombre,
              orden: d.orden,
              bloques: List.from(d.bloques),
            ),
          )
          .toList(),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────
  int? _resolveBlockIndex(int? blockIndex) {
    final dia = _diaActivo;
    if (dia == null) return null;
    if (dia.bloques.isEmpty) return null;
    if (blockIndex != null &&
        blockIndex >= 0 &&
        blockIndex < dia.bloques.length) {
      return blockIndex;
    }
    if (_activeBlockIndex != null && _activeBlockIndex! < dia.bloques.length) {
      return _activeBlockIndex;
    }
    return dia.bloques.length - 1;
  }

  bool _isValidExerciseIndex(int blockIndex, int exerciseIndex) {
    final dia = _diaActivo;
    if (dia == null) return false;
    if (blockIndex < 0 || blockIndex >= dia.bloques.length) return false;
    final lista = dia.bloques[blockIndex].ejercicios;
    return exerciseIndex >= 0 && exerciseIndex < lista.length;
  }

  void _resetPendingCombineParams() {
    _pendingCombineSeries = 4;
    _pendingCombineReps = '10';
    notifyListeners();
  }

  void _syncIndicesAfterDayRemoved(int removedDayIndex) {
    if (_activeDayIndex == null) return;
    if (_activeDayIndex == removedDayIndex) {
      _activeDayIndex = _dias.isEmpty ? null : 0;
      _activeBlockIndex = null;
    } else if (_activeDayIndex! > removedDayIndex) {
      _activeDayIndex = _activeDayIndex! - 1;
    }
    cancelCombining();
  }

  void _syncIndicesAfterBlockRemoved(int removedBlockIndex) {
    if (_activeBlockIndex == null) return;
    if (_activeBlockIndex == removedBlockIndex) {
      _activeBlockIndex = _diaActivo!.bloques.isEmpty ? null : 0;
    } else if (_activeBlockIndex! > removedBlockIndex) {
      _activeBlockIndex = _activeBlockIndex! - 1;
    }
  }

  void _syncIndicesAfterExerciseRemoved(int blockIndex, int removedIndex) {
    if (_combiningBlockIndex == blockIndex && _combiningExerciseIndex != null) {
      if (_combiningExerciseIndex == removedIndex) {
        cancelCombining();
      } else if (_combiningExerciseIndex! > removedIndex) {
        _combiningExerciseIndex = _combiningExerciseIndex! - 1;
      }
    }
  }
}
