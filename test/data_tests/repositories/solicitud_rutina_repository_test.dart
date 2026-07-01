import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/data/repositories/solicitud_rutina_repository.dart';
import '../../mocks/mock_solicitud_rutina_repository.dart';

void main() {
  group('SolicitudRutinaRepository - contrato', () {
    late SolicitudRutinaRepository repository;

    setUp(() {
      repository = MockSolicitudRutinaRepository();
    });

    test('getSolicitudes debe retornar lista de solicitudes', () async {
      // Act
      final result = await repository.getSolicitudes();

      // Assert
      expect(result, isA<List<SolicitudRutina>>());
    });

    test(
      'createSolicitud debe retornar el id de la solicitud creada',
      () async {
        // Arrange
        final solicitud = SolicitudRutina(
          idAlumno: 'abc-123',
          fechaSolicitud: DateTime.now(),
          notas: 'Quiero cambiar mi rutina',
        );

        // Act
        final id = await repository.createSolicitud(solicitud);

        // Assert
        expect(id, isNotNull);
        expect(id, greaterThan(0));
      },
    );

    test('deleteSolicitud debe completarse sin errores', () async {
      // Act + Assert
      expect(() async => await repository.deleteSolicitud(1), returnsNormally);
    });

    test('contarSolicitudesPendientes debe retornar un entero', () async {
      // Act
      final count = await repository.contarSolicitudesPendientes();

      // Assert
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });
  });
}
