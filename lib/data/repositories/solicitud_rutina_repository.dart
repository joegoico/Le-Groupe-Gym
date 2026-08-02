import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';

abstract class SolicitudRutinaRepository {
  Future<List<SolicitudRutina>> getSolicitudes();
  Future<int> createSolicitud(SolicitudRutina solicitud);
  Future<void> deleteSolicitud(int idSolicitud);
  Future<int> contarSolicitudesPendientes();
}

class SupabaseSolicitudRutinaRepository implements SolicitudRutinaRepository {
  final SupabaseClient supabaseClient;

  SupabaseSolicitudRutinaRepository({required this.supabaseClient});

  @override
  Future<List<SolicitudRutina>> getSolicitudes() async {
    try {
      // Mágia de Supabase: '*, alumnos(nombre, apellido)' le dice a PostgREST que traiga
      // todos los campos de la solicitud y que haga un JOIN automático con la tabla
      // 'alumnos' (o como se llame en tu BD) trayendo solo nombre y apellido.
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Solicitudes_Rutina')
          .select('*, Alumno(Nombre, Apellido)')
          .eq('user_id', userId)
          .order('fecha_solicitud', ascending: false);

      return (response as List<dynamic>)
          .map((json) => SolicitudRutina.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener solicitudes: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<int> createSolicitud(SolicitudRutina solicitud) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Solicitudes_Rutina')
          .insert({...solicitud.toMap(), 'user_id': userId})
          .select('id_solicitud')
          .single();

      return response['id_solicitud'] as int;
    } on PostgrestException catch (e) {
      throw Exception('Error al crear solicitud: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> deleteSolicitud(int idSolicitud) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      await supabaseClient
          .from('Solicitudes_Rutina')
          .delete()
          .eq('id_solicitud', idSolicitud)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar solicitud: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<int> contarSolicitudesPendientes() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Solicitudes_Rutina')
          .select()
          .eq('user_id', userId)
          .count();

      return response.count;
    } on PostgrestException catch (e) {
      throw Exception('Error al contar solicitudes: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
