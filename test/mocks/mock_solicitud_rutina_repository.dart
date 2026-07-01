import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/data/repositories/solicitud_rutina_repository.dart';

class MockSolicitudRutinaRepository implements SolicitudRutinaRepository {
  final List<SolicitudRutina> _mockData = [
    SolicitudRutina(
      idSolicitud: 1,
      idAlumno: 'abc-123',
      fechaSolicitud: DateTime(2026, 1, 1),
      notas: 'Quiero cambiar mi rutina de piernas',
    ),
    SolicitudRutina(
      idSolicitud: 2,
      idAlumno: 'def-456',
      fechaSolicitud: DateTime(2026, 1, 2),
    ),
  ];

  @override
  Future<List<SolicitudRutina>> getSolicitudes() async {
    return List.from(_mockData);
  }

  @override
  Future<int> createSolicitud(SolicitudRutina solicitud) async {
    return 99;
  }

  @override
  Future<void> deleteSolicitud(int idSolicitud) async {}

  @override
  Future<int> contarSolicitudesPendientes() async {
    return _mockData.length;
  }
}
