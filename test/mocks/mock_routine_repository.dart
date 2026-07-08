import 'package:le_groupe_gym/data/models/alumno_model.dart';
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

  @override
  Future<List<({Rutina rutina, Alumno alumno})>> getRutinas() async {
    return [
      (
        rutina: Rutina(
          idRutina: 1,
          nombre: 'Hipertrofia - Pecho',
          idAlumno: 'abc-123',
          fechaCreacion: DateTime(2026, 1, 1),
        ),
        alumno: Alumno(
          idAlumno: 'abc-123',
          nombre: 'Juan',
          apellido: 'Pérez',
          aplicaDescuento: false,
        ),
      ),
    ];
  }
}
