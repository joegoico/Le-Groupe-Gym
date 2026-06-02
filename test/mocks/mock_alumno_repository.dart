import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/repositories/alumno_repository.dart';

class MockAlumnoRepository implements AlumnoRepository {
  @override
  Future<List<Alumno>> getAlumnos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Alumno(
        idAlumno: 'abc-123',
        nombre: 'Juan',
        apellido: 'Pérez',
        mail: 'juan@mail.com',
        aplicaDescuento: false,
      ),
      Alumno(
        idAlumno: 'def-456',
        nombre: 'María',
        apellido: 'García',
        mail: null,
        aplicaDescuento: true,
      ),
    ];
  }
}
