import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/repositories/alumno_repository.dart';
import 'mocks/mock_alumno_repository.dart';

void main() {
  group('AlumnoRepository Tests - Mock Implementation', () {
    late AlumnoRepository repository;

    setUp(() {
      // Arrange
      repository = MockAlumnoRepository();
    });

    test('getAlumnos debe retornar una lista no vacía', () async {
      // Act
      final alumnos = await repository.getAlumnos();

      // Assert
      expect(alumnos, isNotEmpty);
    });

    test('cada alumno debe tener id, nombre y apellido no vacíos', () async {
      // Act
      final alumnos = await repository.getAlumnos();

      // Assert
      for (final alumno in alumnos) {
        expect(alumno.idAlumno, isNotEmpty);
        expect(alumno.nombre, isNotEmpty);
        expect(alumno.apellido, isNotEmpty);
      }
    });

    test('mail puede ser nulo en algún alumno', () async {
      // Act
      final alumnos = await repository.getAlumnos();

      // Assert
      final tieneAlumnoSinMail = alumnos.any((a) => a.mail == null);
      expect(tieneAlumnoSinMail, isTrue);
    });

    test('nombreCompleto concatena correctamente nombre y apellido', () async {
      // Act
      final alumnos = await repository.getAlumnos();
      final primero = alumnos.first;

      // Assert
      expect(primero.nombreCompleto, '${primero.nombre} ${primero.apellido}');
    });
  });
}
