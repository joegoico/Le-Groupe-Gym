import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';

void main() {
  group('SolicitudRutina Model Tests', () {
    test('debe instanciar correctamente', () {
      // Arrange + Act
      final solicitud = SolicitudRutina(
        idSolicitud: 1,
        idAlumno: 'abc-123',
        fechaSolicitud: DateTime(2026, 1, 1),
        notas: 'Quiero cambiar mi rutina de piernas',
      );

      // Assert
      expect(solicitud.idSolicitud, 1);
      expect(solicitud.idAlumno, 'abc-123');
      expect(solicitud.notas, 'Quiero cambiar mi rutina de piernas');
    });

    test('debe instanciar sin notas', () {
      // Arrange + Act
      final solicitud = SolicitudRutina(
        idSolicitud: 2,
        idAlumno: 'def-456',
        fechaSolicitud: DateTime(2026, 1, 1),
      );

      // Assert
      expect(solicitud.notas, isNull);
    });

    test('fromMap debe mapear correctamente desde Supabase', () {
      // Arrange
      final jsonMock = {
        'id_solicitud': 1,
        'id_alumno': 'abc-123',
        'fecha_solicitud': '2026-01-01T10:00:00.000Z',
        'notas': 'Cambiar rutina de pecho',
      };

      // Act
      final solicitud = SolicitudRutina.fromMap(jsonMock);

      // Assert
      expect(solicitud.idSolicitud, 1);
      expect(solicitud.idAlumno, 'abc-123');
      expect(solicitud.notas, 'Cambiar rutina de pecho');
    });

    test('toMap debe exportar la estructura correcta para Supabase', () {
      // Arrange
      final solicitud = SolicitudRutina(
        idSolicitud: 1,
        idAlumno: 'abc-123',
        fechaSolicitud: DateTime(2026, 1, 1),
        notas: 'Cambiar rutina',
      );

      // Act
      final mapa = solicitud.toMap();

      // Assert
      expect(mapa['id_alumno'], 'abc-123');
      expect(mapa['notas'], 'Cambiar rutina');
      expect(mapa.containsKey('id_solicitud'), isFalse);
      expect(mapa.containsKey('fecha_solicitud'), isFalse);
    });
  });
}
