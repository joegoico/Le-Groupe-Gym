import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';

abstract class AlumnoRepository {
  Future<List<Alumno>> getAlumnos({int limit = 50, int offset = 0});

  /// Busca alumnos cuyo nombre o apellido contenga [query].
  /// Retorna como máximo [limit] resultados (default 10).
  Future<List<Alumno>> searchAlumnos(String query, {int limit = 10});
  Future<Alumno?> getAlumnoById(String idAlumno);

  /// Crea un nuevo alumno y retorna el id generado.
  Future<String> createAlumno(Alumno alumno);

  /// Actualiza los datos de un alumno existente.
  Future<void> updateAlumno(Alumno alumno);

  /// Elimina el alumno con [idAlumno].
  Future<void> deleteAlumno(String idAlumno);
}

class SupabaseAlumnoRepository implements AlumnoRepository {
  final SupabaseClient supabaseClient;

  SupabaseAlumnoRepository({required this.supabaseClient});

  @override
  Future<List<Alumno>> getAlumnos({int limit = 50, int offset = 0}) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;

      final response = await supabaseClient
          .from('Alumno')
          .select('id_alumno, "Nombre", "Apellido", "Mail"')
          .eq('user_id', userId)
          .order('"Apellido"', ascending: true)
          .range(offset, offset + limit - 1);
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
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      final pattern = '%$query%';
      final response = await supabaseClient
          .from('Alumno')
          .select('id_alumno, "Nombre", "Apellido", "Mail"')
          .or('"Nombre".ilike.$pattern,"Apellido".ilike.$pattern')
          .eq('user_id', userId)
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
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Alumno')
          .select()
          .eq('id_alumno', idAlumno)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Alumno.fromMap(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener alumno: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<String> createAlumno(Alumno alumno) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Alumno')
          .insert({
            'Nombre': alumno.nombre,
            'Apellido': alumno.apellido,
            'Mail': alumno.mail,
            'user_id': userId,
          })
          .select('id_alumno')
          .single();
      return response['id_alumno'] as String;
    } on PostgrestException catch (e) {
      throw Exception('Error al crear alumno: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al crear alumno: $e');
    }
  }

  @override
  Future<void> updateAlumno(Alumno alumno) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      await supabaseClient
          .from('Alumno')
          .update({
            'Nombre': alumno.nombre,
            'Apellido': alumno.apellido,
            'Mail': alumno.mail,
          })
          .eq('id_alumno', alumno.idAlumno)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar alumno: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar alumno: $e');
    }
  }

  @override
  Future<void> deleteAlumno(String idAlumno) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      await supabaseClient
          .from('Alumno')
          .delete()
          .eq('id_alumno', idAlumno)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar alumno: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al eliminar alumno: $e');
    }
  }
}
