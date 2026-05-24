import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';

class Rutina {
  final int? idRutina; // Puede ser null si la rutina todavía no se guardó en la base de datos
  final String nombre;
  final List<EjercicioRutina> ejercicios;

  Rutina({
    this.idRutina,
    required this.nombre,
    required this.ejercicios,
  });

  // Clona la instancia controlando la mutación de estados en Flutter
  Rutina copyWith({
    int? idRutina,
    String? nombre,
    List<EjercicioRutina>? ejercicios,
  }) {
    return Rutina(
      idRutina: idRutina ?? this.idRutina,
      nombre: nombre ?? this.nombre,
      ejercicios: ejercicios ?? this.ejercicios,
    );
  }

  // Reconstruye la cabecera desde la base de datos de Supabase
  factory Rutina.fromMap(Map<String, dynamic> map, {List<EjercicioRutina> ejercicios = const []}) {
    return Rutina(
      idRutina: map['id_rutina'] as int?,
      nombre: map['nombre'] as String,
      ejercicios: ejercicios,
    );
  }

  // Exporta la cabecera para insertar o actualizar en la tabla 'rutinas'
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nombre': nombre,
    };
    
    if (idRutina != null) {
      map['id_rutina'] = idRutina;
    }
    
    return map;
  }
}