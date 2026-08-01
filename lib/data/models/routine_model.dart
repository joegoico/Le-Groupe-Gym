import 'package:le_groupe_gym/data/models/dia_rutina_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';

class Rutina {
  final int? idRutina;
  final String? idAlumno;
  final String nombre;
  final List<DiaRutina> dias; // 👈 cambia de bloques a dias
  final DateTime? fechaCreacion;
  final String? notasGenerales;
  final String? urlPdf;
  final bool esPredeterminada;

  Rutina({
    this.idRutina,
    this.idAlumno,
    required this.nombre,
    List<DiaRutina>? dias,
    this.fechaCreacion,
    this.notasGenerales,
    this.urlPdf,
    this.esPredeterminada = false,
  }) : dias = dias ?? [];

  // Getter de compatibilidad para acceder a todos los ejercicios
  List<EjercicioRutina> get ejercicios =>
      dias.expand((d) => d.bloques.expand((b) => b.ejercicios)).toList();

  Rutina copyWith({
    int? idRutina,
    String? idAlumno,
    String? nombre,
    List<DiaRutina>? dias,
    DateTime? fechaCreacion,
    String? notasGenerales,
    String? urlPdf,
    bool? esPredeterminada,
  }) {
    return Rutina(
      idRutina: idRutina ?? this.idRutina,
      idAlumno: idAlumno ?? this.idAlumno,
      nombre: nombre ?? this.nombre,
      dias: dias ?? this.dias,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      notasGenerales: notasGenerales ?? this.notasGenerales,
      urlPdf: urlPdf ?? this.urlPdf,
      esPredeterminada: esPredeterminada ?? this.esPredeterminada,
    );
  }

  factory Rutina.fromMap(Map<String, dynamic> map, {List<DiaRutina>? dias}) {
    return Rutina(
      idRutina: map['id_rutina'] as int?,
      idAlumno: map['id_alumno'] as String?,
      nombre: map['nombre_rutina'] as String,
      dias: dias ?? [],
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'] as String)
          : null,
      notasGenerales: map['notas_generales'] as String?,
      urlPdf: map['url_pdf'] as String?,
      esPredeterminada: map['es_predeterminada'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre_rutina': nombre,
      if (idRutina != null) 'id_rutina': idRutina,
      if (idAlumno != null) 'id_alumno': idAlumno,
      if (notasGenerales != null) 'notas_generales': notasGenerales,
      if (urlPdf != null) 'url_pdf': urlPdf,
      if (esPredeterminada) 'es_predeterminada': esPredeterminada,
    };
  }
}
