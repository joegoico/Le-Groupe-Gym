class SolicitudRutina {
  final int? idSolicitud;
  final String idAlumno;
  final DateTime fechaSolicitud;
  final String? notas;

  SolicitudRutina({
    this.idSolicitud,
    required this.idAlumno,
    required this.fechaSolicitud,
    this.notas,
  });

  factory SolicitudRutina.fromMap(Map<String, dynamic> map) {
    return SolicitudRutina(
      idSolicitud: map['id_solicitud'] as int?,
      idAlumno: map['id_alumno'] as String,
      fechaSolicitud: DateTime.parse(map['fecha_solicitud'] as String),
      notas: map['notas'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id_alumno': idAlumno, if (notas != null) 'notas': notas};
  }

  SolicitudRutina copyWith({
    int? idSolicitud,
    String? idAlumno,
    DateTime? fechaSolicitud,
    String? notas,
  }) {
    return SolicitudRutina(
      idSolicitud: idSolicitud ?? this.idSolicitud,
      idAlumno: idAlumno ?? this.idAlumno,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      notas: notas ?? this.notas,
    );
  }
}
