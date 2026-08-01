import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/repositories/routine_repository.dart';
import 'package:le_groupe_gym/data/models/dia_rutina_model.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';

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
  Future<void> deleteRoutine(int idRutina) async {
    // Mock
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
        alumno: Alumno(idAlumno: 'abc-123', nombre: 'Juan', apellido: 'Pérez'),
      ),
    ];
  }

  @override
  Future<void> updateRoutine(Rutina rutina) async {
    // Mock — no hace nada
  }
  @override
  Future<Rutina?> getRutinaCompleta(int idRutina) async {
    return Rutina(
      idRutina: idRutina,
      nombre: 'Rutina Mock',
      idAlumno: 'abc-123',
      dias: [
        DiaRutina(
          idDia: 1,
          nombre: 'Día 1',
          orden: 0,
          bloques: [
            BloqueRutina(
              id: 'b1',
              nombre: 'Bloque 1',
              ejercicios: [
                EjercicioRutina(
                  ejercicio: Ejercicio(
                    idEjercicio: 1,
                    nombre: 'Press Banca',
                    categorias: [],
                  ),
                  series: 4,
                  repeticiones: '10',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<List<({Rutina rutina, Alumno alumno})>> getRutinasPorAlumno(
    String idAlumno,
  ) async {
    final todas = await getRutinas();
    return todas.where((r) => r.alumno.idAlumno == idAlumno).toList();
  }

  @override
  Future<List<Rutina>> getRutinasPredeterminadas() async {
    return [
      Rutina(
        idRutina: 101,
        nombre: 'Rutina Fuerza',
        esPredeterminada: true,
        fechaCreacion: DateTime(2026, 1, 1),
      ),
      Rutina(
        idRutina: 102,
        nombre: 'Rutina Hipertrofia',
        esPredeterminada: true,
        fechaCreacion: DateTime(2026, 2, 15),
      ),
    ];
  }
}
