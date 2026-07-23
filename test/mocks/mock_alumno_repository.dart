import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/repositories/alumno_repository.dart';

class MockAlumnoRepository implements AlumnoRepository {
  final List<Alumno> _alumnos = [
    Alumno(
      idAlumno: 'abc-123',
      nombre: 'Juan',
      apellido: 'Pérez',
      mail: 'juan@mail.com',
      aplicaDescuento: false,
    ),
    Alumno(
      idAlumno: 'luc-001',
      nombre: 'Lucas',
      apellido: 'Benítez',
      mail: 'lucas@mail.com',
      aplicaDescuento: false,
    ),
    Alumno(
      idAlumno: 'def-456',
      nombre: 'María',
      apellido: 'García',
      mail: null,
      aplicaDescuento: true,
    ),
    Alumno(
      idAlumno: 'ghi-789',
      nombre: 'Julia',
      apellido: 'López',
      mail: 'julia@mail.com',
      aplicaDescuento: false,
    ),
    Alumno(
      idAlumno: 'jkl-012',
      nombre: 'Julián',
      apellido: 'Martínez',
      mail: 'julian@mail.com',
      aplicaDescuento: false,
    ),
    Alumno(
      idAlumno: 'mno-345',
      nombre: 'Julieta',
      apellido: 'Rodríguez',
      mail: 'julieta@mail.com',
      aplicaDescuento: true,
    ),
    Alumno(
      idAlumno: 'pqr-678',
      nombre: 'Julio',
      apellido: 'Fernández',
      mail: 'julio@mail.com',
      aplicaDescuento: false,
    ),
    Alumno(
      idAlumno: 'stu-901',
      nombre: 'Juana',
      apellido: 'Díaz',
      mail: 'juana@mail.com',
      aplicaDescuento: false,
    ),
    Alumno(
      idAlumno: 'vwx-234',
      nombre: 'Justina',
      apellido: 'Sánchez',
      mail: 'justina@mail.com',
      aplicaDescuento: true,
    ),
    Alumno(
      idAlumno: 'yza-567',
      nombre: 'Junco',
      apellido: 'Ramírez',
      mail: 'junco@mail.com',
      aplicaDescuento: false,
    ),
    Alumno(
      idAlumno: 'bcd-890',
      nombre: 'Justa',
      apellido: 'Torres',
      mail: 'justa@mail.com',
      aplicaDescuento: false,
    ),
    Alumno(
      idAlumno: 'efg-123',
      nombre: 'Juvenal',
      apellido: 'Flores',
      mail: 'juvenal@mail.com',
      aplicaDescuento: true,
    ),
    Alumno(
      idAlumno: 'hij-456',
      nombre: 'Justino',
      apellido: 'Acosta',
      mail: 'justino@mail.com',
      aplicaDescuento: false,
    ),
    Alumno(
      idAlumno: 'klm-789',
      nombre: 'Pedro',
      apellido: 'Gómez',
      mail: 'pedro@mail.com',
      aplicaDescuento: false,
    ),
    Alumno(
      idAlumno: 'nop-012',
      nombre: 'Ana',
      apellido: 'Ruiz',
      mail: 'ana@mail.com',
      aplicaDescuento: true,
    ),
    Alumno(
      idAlumno: 'qrs-345',
      nombre: 'Carlos',
      apellido: 'Juárez',
      mail: 'carlos@mail.com',
      aplicaDescuento: false,
    ),
  ];

  @override
  Future<List<Alumno>> getAlumnos() async {
    return List.unmodifiable(_alumnos);
  }

  @override
  Future<List<Alumno>> searchAlumnos(String query, {int limit = 10}) async {
    final lowerQuery = query.toLowerCase();
    final filtered = _alumnos
        .where(
          (a) =>
              a.nombre.toLowerCase().contains(lowerQuery) ||
              a.apellido.toLowerCase().contains(lowerQuery),
        )
        .take(limit)
        .toList();
    return filtered;
  }

  @override
  Future<Alumno?> getAlumnoById(String idAlumno) async {
    return _alumnos.firstWhere(
      (a) => a.idAlumno == idAlumno,
      orElse: () => _alumnos.first,
    );
  }

  @override
  Future<String> createAlumno(Alumno alumno) async {
    final newId = 'mock-${_alumnos.length + 1}';
    _alumnos.add(
      Alumno(
        idAlumno: newId,
        nombre: alumno.nombre,
        apellido: alumno.apellido,
        mail: alumno.mail,
        aplicaDescuento: alumno.aplicaDescuento,
      ),
    );
    return newId;
  }

  @override
  Future<void> updateAlumno(Alumno alumno) async {
    final index = _alumnos.indexWhere((a) => a.idAlumno == alumno.idAlumno);
    if (index != -1) _alumnos[index] = alumno;
  }

  @override
  Future<void> deleteAlumno(String idAlumno) async {
    _alumnos.removeWhere((a) => a.idAlumno == idAlumno);
  }
}
