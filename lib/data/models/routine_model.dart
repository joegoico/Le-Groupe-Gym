import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';

class Rutina {
  final int? idRutina;
  final String? idAlumno;
  final String nombre;
  final List<BloqueRutina> bloques;
  final DateTime? fechaCreacion;
  final String? notasGenerales;

  Rutina({
    this.idRutina,
    this.idAlumno,
    required this.nombre,
    List<BloqueRutina>? bloques,
    List<EjercicioRutina>? ejercicios,
    this.fechaCreacion,
    this.notasGenerales,
  }) : bloques = bloques ??
            (ejercicios != null && ejercicios.isNotEmpty
                ? [
                    BloqueRutina(
                      id: 'bloque-1',
                      nombre: 'Bloque 1',
                      ejercicios: ejercicios,
                    ),
                  ]
                : []);

  /// Lista plana de tarjetas (todos los bloques en orden).
  List<EjercicioRutina> get ejercicios =>
      bloques.expand((b) => b.ejercicios).toList(growable: false);

  int get totalEjercicios => ejercicios.length;

  Rutina copyWith({
    int? idRutina,
    String? idAlumno,
    String? nombre,
    List<BloqueRutina>? bloques,
    DateTime? fechaCreacion,
    String? notasGenerales,
  }) {
    return Rutina(
      idRutina: idRutina ?? this.idRutina,
      idAlumno: idAlumno ?? this.idAlumno,
      nombre: nombre ?? this.nombre,
      bloques: bloques ?? this.bloques,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      notasGenerales: notasGenerales ?? this.notasGenerales,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre_rutina': nombre,
      if (idRutina != null) 'id_rutina': idRutina,
      if (idAlumno != null) 'id_alumno': idAlumno,
    };
  }

  factory Rutina.fromMap(Map<String, dynamic> map, {List<EjercicioRutina> ejercicios = const []}) {
    return Rutina(
      idRutina: map['id_rutina'] as int?,
      idAlumno: map['id_alumno'] as String?,
      nombre: map['nombre_rutina'] as String,
      ejercicios: ejercicios,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'] as String)
          : null,
      notasGenerales: map['notas_generales'] as String?,
    );
  }

  /// Filas para insertar en `Rutina_Ejercicios` (orden global; superserie comparte `id_combo`).
  List<Map<String, dynamic>> buildEjerciciosInsertPayload(int idRutina) {
    final filas = <Map<String, dynamic>>[];
    var orden = 0;
    var siguienteIdCombo = 1;

    for (final bloque in bloques) {
      for (final tarjeta in bloque.ejercicios) {
        final idCombo = tarjeta.esSuperserie ? siguienteIdCombo++ : null;

        for (final miembro in tarjeta.miembros) {
          filas.add({
            'id_rutina': idRutina,
            'id_ejercicio': miembro.ejercicio.idEjercicio,
            'series': miembro.series,
            'repeticiones': miembro.repeticiones,
            'orden': orden++,
            if (idCombo != null) 'id_combo': idCombo,
            if (notasGenerales != null) 'notas_generales': notasGenerales,
          });
        }
      }
    }

    return filas;
  }
}
