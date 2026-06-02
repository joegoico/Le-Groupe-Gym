import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';

/// Bloque de entrenamiento dentro de una rutina (p. ej. calentamiento, fuerza).
class BloqueRutina {
  final String id;
  String nombre;
  final List<EjercicioRutina> ejercicios;

  BloqueRutina({
    required this.id,
    required this.nombre,
    List<EjercicioRutina>? ejercicios,
  }) : ejercicios = ejercicios ?? [];

  int get cantidadEjercicios => ejercicios.length;

  bool get estaVacio => ejercicios.isEmpty;

  BloqueRutina copyWith({
    String? id,
    String? nombre,
    List<EjercicioRutina>? ejercicios,
  }) {
    return BloqueRutina(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      ejercicios: ejercicios ?? List.from(this.ejercicios),
    );
  }
}

/// No se puede dejar un bloque sin ejercicios ni eliminar el último ejercicio del único bloque.
class BloqueMinimoEjerciciosException implements Exception {
  final String message;
  const BloqueMinimoEjerciciosException([
    this.message = 'Cada bloque debe tener al menos un ejercicio.',
  ]);

  @override
  String toString() => message;
}

/// No se puede eliminar un bloque que aún tiene ejercicios.
class BloqueConEjerciciosException implements Exception {
  final String message;
  const BloqueConEjerciciosException([
    this.message = 'Mové los ejercicios a otro bloque antes de eliminarlo.',
  ]);

  @override
  String toString() => message;
}
