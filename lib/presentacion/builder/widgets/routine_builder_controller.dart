import 'package:flutter/material.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:flutter/foundation.dart';

class RoutineBuilderController extends ChangeNotifier {
  final List<BloqueRutina> _bloques = [];
  int? _activeBlockIndex;
  int? _combiningBlockIndex;
  int? _combiningExerciseIndex;
  int _pendingCombineSeries = 4;
  String _pendingCombineReps = '10';
  int _blockIdCounter = 0;

  List<BloqueRutina> get bloques => List.unmodifiable(_bloques);

  int? get activeBlockIndex => _activeBlockIndex;

  List<EjercicioRutina> get currentRoutine =>
      _bloques.expand((b) => b.ejercicios).toList(growable: false);

  int get totalEjercicios => currentRoutine.length;

  bool get isEmpty => _bloques.isEmpty || totalEjercicios == 0;

  int? get combiningBlockIndex => _combiningBlockIndex;

  int? get combiningExerciseIndex => _combiningExerciseIndex;

  int get pendingCombineSeries => _pendingCombineSeries;

  String get pendingCombineReps => _pendingCombineReps;

  bool get isSelectingForCombine => _combiningBlockIndex != null;

  String? get combiningTargetExerciseName {
    if (_combiningBlockIndex == null || _combiningExerciseIndex == null) {
      return null;
    }
    final bloque = _bloques[_combiningBlockIndex!];
    return bloque.ejercicios[_combiningExerciseIndex!].ejercicio.nombre;
  }

  bool isCombiningAt(int blockIndex, int exerciseIndex) =>
      _combiningBlockIndex == blockIndex &&
      _combiningExerciseIndex == exerciseIndex;

  /// Compatibilidad con índice plano (primer bloque que contiene el índice acumulado).
  @Deprecated('Usar isCombiningAt(blockIndex, exerciseIndex)')
  bool isCombiningAtFlat(int flatIndex) {
    final pos = _flatToPosition(flatIndex);
    if (pos == null) return false;
    return isCombiningAt(pos.$1, pos.$2);
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
      bloques: _bloques
          .map(
            (b) => BloqueRutina(
              id: b.id,
              nombre: b.nombre,
              ejercicios: List.from(b.ejercicios),
            ),
          )
          .toList(),
    );
  }

  int addBlock({String? nombre}) {
    _blockIdCounter++;
    final bloque = BloqueRutina(
      id: 'bloque-$_blockIdCounter',
      nombre: nombre ?? 'Bloque ${_bloques.length + 1}',
    );
    _bloques.add(bloque);
    notifyListeners();
    _activeBlockIndex = _bloques.length - 1;
    return _activeBlockIndex!;
  }

  void selectBlock(int blockIndex) {
    if (blockIndex >= 0 && blockIndex < _bloques.length) {
      _activeBlockIndex = blockIndex;
    }
    notifyListeners();
  }

  /// Elimina un bloque vacío. Falla si tiene ejercicios o es el único bloque.
  bool removeBlock(int blockIndex) {
    if (blockIndex < 0 || blockIndex >= _bloques.length) return false;
    if (_bloques.length <= 1) return false;

    _bloques.removeAt(blockIndex);
    _syncIndicesAfterBlockRemoved(blockIndex);
    notifyListeners();
    return true;
  }

  bool addExercise(Ejercicio ejercicio, {int? blockIndex}) {
    final target = _resolveBlockIndex(blockIndex);
    if (target == null) {
      addBlock();
      addExercise(ejercicio, blockIndex: _bloques.length - 1);
      return true;
    }
    final yaExiste = _bloques.any(
      (bloque) => bloque.ejercicios.any(
        (e) => e.ejercicio.idEjercicio == ejercicio.idEjercicio,
      ),
    );
    if (yaExiste) return false;

    _bloques[target].ejercicios.add(
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
    bool exerciseAdded = addExercise(ejercicio);
    notifyListeners();
    return exerciseAdded;
  }

  bool _combineFromSidebar(Ejercicio ejercicio) {
    final blockIndex = _combiningBlockIndex!;
    final exerciseIndex = _combiningExerciseIndex!;
    if (_ejercicioYaEnTarjeta(blockIndex, exerciseIndex, ejercicio)) {
      return false;
    }

    confirmCombine(
      blockIndex: blockIndex,
      exerciseIndex: exerciseIndex,
      ejercicio: ejercicio,
      series: _pendingCombineSeries,
      repeticiones: _pendingCombineReps,
    );
    notifyListeners();
    return true;
  }

  bool _ejercicioYaEnTarjeta(
    int blockIndex,
    int exerciseIndex,
    Ejercicio ejercicio,
  ) {
    notifyListeners();
    return _bloques[blockIndex].ejercicios[exerciseIndex].miembros.any(
      (m) => m.ejercicio.idEjercicio == ejercicio.idEjercicio,
    );
  }

  /// Elimina un ejercicio. Falla si es el único del bloque (mínimo 1 por bloque).
  bool removeExercise(int blockIndex, int exerciseIndex) {
    if (!_isValidExerciseIndex(blockIndex, exerciseIndex)) return false;
    if (_bloques[blockIndex].ejercicios.length <= 1) return false;

    _bloques[blockIndex].ejercicios.removeAt(exerciseIndex);
    _syncIndicesAfterExerciseRemoved(blockIndex, exerciseIndex);
    notifyListeners();
    return true;
  }

  @Deprecated('Usar removeExercise(blockIndex, exerciseIndex)')
  void removeExerciseFlat(int flatIndex) {
    final pos = _flatToPosition(flatIndex);
    if (pos != null) removeExercise(pos.$1, pos.$2);
  }

  bool moveExercise({
    required int fromBlockIndex,
    required int fromExerciseIndex,
    required int toBlockIndex,
    int? toExerciseIndex,
  }) {
    if (!_isValidExerciseIndex(fromBlockIndex, fromExerciseIndex)) return false;
    if (toBlockIndex < 0 || toBlockIndex >= _bloques.length) return false;
    if (fromBlockIndex == toBlockIndex) return false;

    final source = _bloques[fromBlockIndex];
    if (source.ejercicios.length <= 1) return false;

    final tarjeta = source.ejercicios.removeAt(fromExerciseIndex);
    final destino = _bloques[toBlockIndex];
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
    _bloques.clear();
    _activeBlockIndex = null;
    _combiningBlockIndex = null;
    _combiningExerciseIndex = null;
    _resetPendingCombineParams();
    notifyListeners();
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

  void updateMemberParams({
    required int blockIndex,
    required int exerciseIndex,
    required int slotIndex,
    int? series,
    String? repeticiones,
    String? notas,
  }) {
    if (!_isValidExerciseIndex(blockIndex, exerciseIndex)) return;
    _bloques[blockIndex].ejercicios[exerciseIndex].actualizarMiembro(
      slotIndex,
      series: series,
      repeticiones: repeticiones,
      notas: notas,
    );
  }

  void updatePendingCombineParams({int? series, String? repeticiones}) {
    if (_combiningBlockIndex == null) return;
    if (series != null) _pendingCombineSeries = series;
    if (repeticiones != null) _pendingCombineReps = repeticiones;
  }

  void startCombining(int blockIndex, int exerciseIndex) {
    if (!_isValidExerciseIndex(blockIndex, exerciseIndex)) return;
    if (_bloques[blockIndex].ejercicios[exerciseIndex].esSuperserie) return;
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

  void _resetPendingCombineParams() {
    _pendingCombineSeries = 4;
    _pendingCombineReps = '10';
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
    _bloques[blockIndex].ejercicios[exerciseIndex].combinarCon(
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

  void reorderExerciseInBlock(int blockIndex, int oldIndex, int newIndex) {
    if (blockIndex < 0 || blockIndex >= _bloques.length) return;
    final lista = _bloques[blockIndex].ejercicios;
    if (oldIndex < 0 || oldIndex >= lista.length) return;
    if (newIndex > oldIndex) newIndex -= 1;
    if (newIndex < 0 || newIndex >= lista.length) return;

    final item = lista.removeAt(oldIndex);
    lista.insert(newIndex, item);
    _syncIndicesAfterExerciseReorder(blockIndex, oldIndex, newIndex);
    notifyListeners();
  }

  void renameBlock(int blockIndex, String nombre) {
    if (blockIndex >= 0 && blockIndex < _bloques.length) {
      _bloques[blockIndex].nombre = nombre;
    }
    notifyListeners();
  }

  int? _resolveBlockIndex(int? blockIndex) {
    if (_bloques.isEmpty) return null;
    if (blockIndex != null && blockIndex >= 0 && blockIndex < _bloques.length) {
      return blockIndex;
    }
    if (_activeBlockIndex != null && _activeBlockIndex! < _bloques.length) {
      return _activeBlockIndex;
    }
    return _bloques.length - 1;
  }

  bool _isValidExerciseIndex(int blockIndex, int exerciseIndex) {
    if (blockIndex < 0 || blockIndex >= _bloques.length) return false;
    final lista = _bloques[blockIndex].ejercicios;
    return exerciseIndex >= 0 && exerciseIndex < lista.length;
  }

  (int, int)? _flatToPosition(int flatIndex) {
    var cursor = 0;
    for (var b = 0; b < _bloques.length; b++) {
      final count = _bloques[b].ejercicios.length;
      if (flatIndex < cursor + count) {
        return (b, flatIndex - cursor);
      }
      cursor += count;
    }
    return null;
  }

  void _syncIndicesAfterBlockRemoved(int removedBlockIndex) {
    if (_activeBlockIndex != null) {
      if (_activeBlockIndex == removedBlockIndex) {
        _activeBlockIndex = (_bloques.isEmpty) ? null : 0;
      } else if (_activeBlockIndex! > removedBlockIndex) {
        _activeBlockIndex = _activeBlockIndex! - 1;
      }
    }
    _adjustCombiningAfterBlockRemoved(removedBlockIndex);
    notifyListeners();
  }

  void _adjustCombiningAfterBlockRemoved(int removedBlockIndex) {
    if (_combiningBlockIndex == null) return;
    if (_combiningBlockIndex == removedBlockIndex) {
      cancelCombining();
    } else if (_combiningBlockIndex! > removedBlockIndex) {
      _combiningBlockIndex = _combiningBlockIndex! - 1;
    }
    notifyListeners();
  }

  void _syncIndicesAfterExerciseRemoved(int blockIndex, int removedIndex) {
    if (_combiningBlockIndex == blockIndex && _combiningExerciseIndex != null) {
      if (_combiningExerciseIndex == removedIndex) {
        cancelCombining();
      } else if (_combiningExerciseIndex! > removedIndex) {
        _combiningExerciseIndex = _combiningExerciseIndex! - 1;
      }
    }
    notifyListeners();
  }

  void _syncIndicesAfterExerciseReorder(
    int blockIndex,
    int oldIndex,
    int newIndex,
  ) {
    if (_combiningBlockIndex != blockIndex || _combiningExerciseIndex == null) {
      return;
    }
    final combining = _combiningExerciseIndex!;
    if (combining == oldIndex) {
      _combiningExerciseIndex = newIndex;
    } else if (combining > oldIndex && combining <= newIndex) {
      _combiningExerciseIndex = combining - 1;
    } else if (combining < oldIndex && combining >= newIndex) {
      _combiningExerciseIndex = combining + 1;
    }
    notifyListeners();
  }
}
