class SolicitudRutina {
  final int? idSolicitud;
  final String idAlumno;
  final DateTime fechaSolicitud;
  final String? notas;
  // Nuevos campos opcionales para almacenar los datos del JOIN
  final String? alumnoNombre;
  final String? alumnoApellido;

  SolicitudRutina({
    this.idSolicitud,
    required this.idAlumno,
    required this.fechaSolicitud,
    this.notas,
    this.alumnoNombre,
    this.alumnoApellido,
  });

  factory SolicitudRutina.fromMap(Map<String, dynamic> map) {
    // Intentamos extraer el mapa anidado que genera el JOIN de Supabase
    final alumnoData = map['Alumno'] as Map<String, dynamic>?;

    return SolicitudRutina(
      idSolicitud: map['id_solicitud'] as int?,
      idAlumno: map['id_alumno'] as String,
      fechaSolicitud: DateTime.parse(map['fecha_solicitud'] as String),
      notas: map['notas'] as String?,
      // Si alumnoData existe, sacamos el nombre y apellido; si no, quedan nulos
      alumnoNombre: alumnoData?['Nombre'] as String?,
      alumnoApellido: alumnoData?['Apellido'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_alumno': idAlumno,
      if (notas != null) 'notas': notas,
      // Nota: No incluimos alumnoNombre ni alumnoApellido aquí porque
      // son datos de solo lectura que le pertenecen a la tabla 'alumnos'.
    };
  }

  SolicitudRutina copyWith({
    int? idSolicitud,
    String? idAlumno,
    DateTime? fechaSolicitud,
    String? notas,
    String? alumnoNombre,
    String? alumnoApellido,
  }) {
    return SolicitudRutina(
      idSolicitud: idSolicitud ?? this.idSolicitud,
      idAlumno: idAlumno ?? this.idAlumno,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      notas: notas ?? this.notas,
      alumnoNombre: alumnoNombre ?? this.alumnoNombre,
      alumnoApellido: alumnoApellido ?? this.alumnoApellido,
    );
  }
}
