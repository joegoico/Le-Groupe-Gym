import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';

abstract class AlumnoRepository {
  Future<List<Alumno>> getAlumnos();
}

class SupabaseAlumnoRepository implements AlumnoRepository {
  final SupabaseClient supabaseClient;

  SupabaseAlumnoRepository({required this.supabaseClient});

  @override
  Future<List<Alumno>> getAlumnos() async {
    try {
      final response = await supabaseClient
          .from('Alumno')
          .select('id_alumno, "Nombre", "Apellido", "Mail", aplica_descuento')
          .order('"Apellido"', ascending: true);

      return (response as List<dynamic>)
          .map((json) => Alumno.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener alumnos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener alumnos: $e');
    }
  }
}
