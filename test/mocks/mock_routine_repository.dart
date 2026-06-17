import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/repositories/routine_repository.dart';

class MockRoutineRepository implements RoutineRepository {
  @override
  Future<int> saveRoutine(Rutina rutina) async {
    return 1;
  }

  @override
  Future<void> updatePdfUrl({
    required int idRutina,
    required String url,
  }) async {
    // Mock — no hace nada
  }
}
