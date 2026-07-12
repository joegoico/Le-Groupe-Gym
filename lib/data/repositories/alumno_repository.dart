import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';

abstract class AlumnoRepository {
  Future<List<Alumno>> getAlumnos();

  /// Busca alumnos cuyo nombre o apellido contenga [query].
  /// Retorna como máximo [limit] resultados (default 10).
  Future<List<Alumno>> searchAlumnos(String query, {int limit = 10});
  Future<Alumno?> getAlumnoById(String idAlumno);
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

  @override
  Future<List<Alumno>> searchAlumnos(String query, {int limit = 10}) async {
    try {
      final pattern = '%$query%';
      final response = await supabaseClient
          .from('Alumno')
          .select('id_alumno, "Nombre", "Apellido", "Mail", aplica_descuento')
          .or('"Nombre".ilike.$pattern,"Apellido".ilike.$pattern')
          .order('"Apellido"', ascending: true)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => Alumno.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al buscar alumnos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al buscar alumnos: $e');
    }
  }

  @override
  Future<Alumno?> getAlumnoById(String idAlumno) async {
    try {
      final response = await supabaseClient
          .from('Alumno')
          .select()
          .eq('id_alumno', idAlumno)
          .maybeSingle();

      if (response == null) return null;
      return Alumno.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener alumno: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
