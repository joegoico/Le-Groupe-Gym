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
      print('Fetching solicitudes from Supabase with Alumnos JOIN...');

      // Mágia de Supabase: '*, alumnos(nombre, apellido)' le dice a PostgREST que traiga
      // todos los campos de la solicitud y que haga un JOIN automático con la tabla
      // 'alumnos' (o como se llame en tu BD) trayendo solo nombre y apellido.
      final response = await supabaseClient
          .from('Solicitudes_Rutina')
          .select('*, Alumno(Nombre, Apellido)')
          .order('fecha_solicitud', ascending: false);

      print('Raw response from Supabase:');
      print(response);

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
      final response = await supabaseClient
          .from('Solicitudes_Rutina')
          .insert(solicitud.toMap())
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
      await supabaseClient
          .from('Solicitudes_Rutina')
          .delete()
          .eq('id_solicitud', idSolicitud);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar solicitud: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<int> contarSolicitudesPendientes() async {
    try {
      final response = await supabaseClient
          .from('Solicitudes_Rutina')
          .select()
          .count();

      return response.count;
    } on PostgrestException catch (e) {
      throw Exception('Error al contar solicitudes: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
