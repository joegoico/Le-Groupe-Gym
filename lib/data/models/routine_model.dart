class RutinaEjercicio {
  final int idRutinaEjercicio;
  final int orden;
  final int series;
  final String repeticiones;
  final int descansoSegundos;
  final String notas;
  final int idEjercicio;
  final String nombreEjercicio;

  RutinaEjercicio({
    required this.idRutinaEjercicio,
    required this.orden,
    required this.series,
    required this.repeticiones,
    required this.descansoSegundos,
    required this.notas,
    required this.idEjercicio,
    required this.nombreEjercicio,
  });

  factory RutinaEjercicio.fromJson(Map<String, dynamic> json) {
    final ejercicioJson = json['Ejercicios'] as Map<String, dynamic>? ?? {};
    
    return RutinaEjercicio(
      idRutinaEjercicio: json['id_rutina_ejercicio'] as int,
      orden: json['orden'] as int,
      series: json['series'] as int,
      repeticiones: json['repeticiones'] as String? ?? '',
      descansoSegundos: json['descanso_segundos'] as int? ?? 0,
      notas: json['notas'] as String? ?? '', // Defensivo por si viene null
      idEjercicio: ejercicioJson['id_ejercicio'] as int? ?? 0,
      nombreEjercicio: ejercicioJson['nombre'] as String? ?? 'Ejercicio sin nombre',
    );
  }
}

class Rutina {
  final int idRutina;
  final String nombreRutina;
  final String alumnoId;
  final DateTime fechaCreacion;
  final List<RutinaEjercicio> ejerciciosAsignados;

  Rutina({
    required this.idRutina,
    required this.nombreRutina,
    required this.alumnoId,
    required this.fechaCreacion,
    required this.ejerciciosAsignados,
  });

  factory Rutina.fromJson(Map<String, dynamic> json) {
    final ejerciciosJsonList = json['Rutina_Ejercicios'] as List? ?? [];
    
    final List<RutinaEjercicio> ejerciciosAsignados = ejerciciosJsonList.map((ejJson) {
      return RutinaEjercicio.fromJson(ejJson as Map<String, dynamic>);
    }).toList();

    return Rutina(
      idRutina: json['id_rutina'] as int,
      nombreRutina: json['nombre_rutina'] as String,
      alumnoId: json['alumno_id'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      ejerciciosAsignados: ejerciciosAsignados,
    );
  }
}