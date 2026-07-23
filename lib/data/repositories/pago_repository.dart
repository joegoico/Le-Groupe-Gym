import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';

abstract class PagoRepository {
  Future<void> insertarPago(Pago pago);
  Future<List<Pago>> getPagosPorAlumnoAno(String idAlumno, int anio);
  Future<Pago?> getUltimoPago(String idAlumno);
}

class SupabasePagoRepository implements PagoRepository {
  final SupabaseClient supabaseClient;

  SupabasePagoRepository({required this.supabaseClient});

  @override
  Future<void> insertarPago(Pago pago) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      await supabaseClient
          .from('Pagos')
          .insert({
            'Fecha_de_pago': pago.fechaDePago.toIso8601String(),
            'monto': pago.monto,
            'medio_de_pago': pago.medioDePago,
            'comentarios': pago.comentarios,
            'id_alumno': pago.idAlumno,
            'cantidad_dias': pago.cantidadDias,
            'user_id': userId,
          });
    } on PostgrestException catch (e) {
      throw Exception('Error al insertar pago: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<List<Pago>> getPagosPorAlumnoAno(String idAlumno, int anio) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      
      final startOfYear = '$anio-01-01';
      final endOfYear = '$anio-12-31';

      final response = await supabaseClient
          .from('Pagos')
          .select()
          .eq('id_alumno', idAlumno)
          .eq('user_id', userId)
          .gte('Fecha_de_pago', startOfYear)
          .lte('Fecha_de_pago', endOfYear)
          .order('Fecha_de_pago', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Pago.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener pagos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<Pago?> getUltimoPago(String idAlumno) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;

      final response = await supabaseClient
          .from('Pagos')
          .select()
          .eq('id_alumno', idAlumno)
          .eq('user_id', userId)
          .order('Fecha_de_pago', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return Pago.fromMap(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener el último pago: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
