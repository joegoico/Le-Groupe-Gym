import 'exercise_model.dart';

class EjercicioRutina {
  final Ejercicio ejercicio;
  int series;
  String repeticiones;
  String descanso;
  String notas;

  EjercicioRutina({
    required this.ejercicio,
    this.series = 4,
    this.repeticiones = '10',
    this.descanso = '60',
    this.notas = '',
  });

  // El patrón copyWith para mutar estados de forma segura en Flutter
  EjercicioRutina copyWith({
    Ejercicio? ejercicio,
    int? series,
    String? repeticiones,
    String? descanso,
    String? notas,
  }) {
    return EjercicioRutina(
      ejercicio: ejercicio ?? this.ejercicio,
      series: series ?? this.series,
      repeticiones: repeticiones ?? this.repeticiones,
      descanso: descanso ?? this.descanso,
      notas: notas ?? this.notas,
    );
  }

  // Transformar un mapa de la base de datos a Objeto de Dart
  factory EjercicioRutina.fromMap(Map<String, dynamic> map, Ejercicio ejercicioBase) {
    return EjercicioRutina(
      ejercicio: ejercicioBase,
      series: map['series'] as int? ?? 4,
      repeticiones: map['repeticiones'] as String? ?? '10',
      descanso: map['descanso'] as String? ?? '60',
      notas: map['notas'] as String? ?? '',
    );
  }

  // Transformar de Objeto a Mapa para insertar en Supabase
  Map<String, dynamic> toMap() {
    return {
      'series': series,
      'repeticiones': repeticiones,
      'descanso': descanso,
      'notas': notas, // Podés mapearlo exactamente al nombre de la columna en la base de datos
    };
  }
}