import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/services/service_storage.dart';

void main() {
  group('StorageService Tests', () {

    test('buildFilePath debe generar un path único con id_rutina y id_alumno', () {
      // Arrange
      final service = StorageService();

      // Act
      final path = service.buildFilePath(
        idRutina: 42,
        idAlumno: 'abc-123',
      );

      // Assert
      expect(path, contains('42'));
      expect(path, contains('abc-123'));
      expect(path, endsWith('.pdf'));
    });

    test('buildFilePath debe generar paths distintos para rutinas distintas', () {
      // Arrange
      final service = StorageService();

      // Act
      final path1 = service.buildFilePath(idRutina: 1, idAlumno: 'abc-123');
      final path2 = service.buildFilePath(idRutina: 2, idAlumno: 'abc-123');

      // Assert
      expect(path1, isNot(equals(path2)));
    });
  });
}
