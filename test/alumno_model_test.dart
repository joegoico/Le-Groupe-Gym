import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';

void main() {
  group('Alumno Model Tests', () {

    test('debe instanciar un Alumno correctamente', () {
      // Arrange
      const idEsperado = 'abc-123';
      const nombreEsperado = 'Juan';
      const apellidoEsperado = 'Pérez';
      const mailEsperado = 'juan@mail.com';

      // Act
      final alumno = Alumno(
        idAlumno: idEsperado,
        nombre: nombreEsperado,
        apellido: apellidoEsperado,
        mail: mailEsperado,
        aplicaDescuento: false,
      );

      // Assert
      expect(alumno.idAlumno, idEsperado);
      expect(alumno.nombre, nombreEsperado);
      expect(alumno.apellido, apellidoEsperado);
      expect(alumno.mail, mailEsperado);
      expect(alumno.aplicaDescuento, isFalse);
    });

    test('fromMap debe reconstruir un Alumno desde la respuesta de Supabase', () {
      // Arrange — refleja exactamente las columnas de la tabla
      final jsonMock = {
        'id_alumno': 'abc-123',
        'Nombre': 'Juan',
        'Apellido': 'Pérez',
        'Mail': 'juan@mail.com',
        'aplica_descuento': false,
      };

      // Act
      final alumno = Alumno.fromMap(jsonMock);

      // Assert
      expect(alumno.idAlumno, 'abc-123');
      expect(alumno.nombre, 'Juan');
      expect(alumno.apellido, 'Pérez');
      expect(alumno.mail, 'juan@mail.com');
      expect(alumno.aplicaDescuento, isFalse);
    });

    test('mail puede ser nulo', () {
      // Arrange
      final jsonMock = {
        'id_alumno': 'abc-123',
        'Nombre': 'Juan',
        'Apellido': 'Pérez',
        'Mail': null,
        'aplica_descuento': false,
      };

      // Act
      final alumno = Alumno.fromMap(jsonMock);

      // Assert
      expect(alumno.mail, isNull);
    });

    test('nombreCompleto debe concatenar nombre y apellido', () {
      // Arrange
      final alumno = Alumno(
        idAlumno: 'abc-123',
        nombre: 'Juan',
        apellido: 'Pérez',
        aplicaDescuento: false,
      );

      // Act
      final resultado = alumno.nombreCompleto;

      // Assert
      expect(resultado, 'Juan Pérez');
    });
  });
}
