import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/data/repositories/solicitud_rutina_repository.dart';

class MockSolicitudRutinaRepository implements SolicitudRutinaRepository {
  // 1. Unificamos los datos falsos aquí, incluyendo los nombres para el JOIN
  final List<SolicitudRutina> _mockData = [
    SolicitudRutina(
      idSolicitud: 1,
      idAlumno: 'abc-123',
      fechaSolicitud: DateTime(2026, 1, 1),
      notas: 'Quiero cambiar mi rutina de piernas',
      alumnoNombre: 'Lucas',
      alumnoApellido: 'Benítez',
    ),
    SolicitudRutina(
      idSolicitud: 2,
      idAlumno: 'def-456',
      fechaSolicitud: DateTime(2026, 1, 2),
      alumnoNombre: 'Micaela',
      alumnoApellido: 'Rossi',
    ),
  ];

  @override
  Future<List<SolicitudRutina>> getSolicitudes() async {
    // 2. Ahora devolvemos la lista real en memoria
    return _mockData;
  }

  @override
  Future<int> createSolicitud(SolicitudRutina solicitud) async {
    // 3. Simulamos la base de datos: generamos un ID y lo guardamos de verdad en el mock
    final nuevoId = _mockData.length + 1;
    final nuevaSolicitud = solicitud.copyWith(idSolicitud: nuevoId);

    _mockData.add(nuevaSolicitud);

    return nuevoId;
  }

  @override
  Future<void> deleteSolicitud(int idSolicitud) async {
    _mockData.removeWhere((s) => s.idSolicitud == idSolicitud);
  }

  @override
  Future<int> contarSolicitudesPendientes() async {
    return _mockData.length;
  }
}
