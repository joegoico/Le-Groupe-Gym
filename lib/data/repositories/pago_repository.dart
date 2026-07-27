import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';

abstract class PagoRepository {
  Future<void> insertarPago(Pago pago);
  Future<List<Pago>> getPagosPorAlumno(String idAlumno, {int? anio, int? mes});
  Future<Pago?> getUltimoPago(String idAlumno);
  Future<void> updatePago(Pago pago);
  Future<void> deletePago(String idPago);
}

class SupabasePagoRepository implements PagoRepository {
  final SupabaseClient supabaseClient;

  SupabasePagoRepository({required this.supabaseClient});

  @override
  Future<void> insertarPago(Pago pago) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      await supabaseClient.from('Pagos').insert({
        'Fecha_de_pago': pago.fechaDePago.toIso8601String(),
        'monto': pago.monto,
        'medio_de_pago': pago.medioDePago,
        'comentarios': pago.comentarios,
        'id_alumno': pago.idAlumno,
        'cantidad_dias': pago.cantidadDias,
        'aplica_descuento': pago.aplicaDescuento,
        'user_id': userId,
      });
    } on PostgrestException catch (e) {
      throw Exception('Error al insertar pago: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<List<Pago>> getPagosPorAlumno(
    String idAlumno, {
    int? anio,
    int? mes,
  }) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;

      var query = supabaseClient
          .from('Pagos')
          .select(
            '"Fecha_de_pago",monto,medio_de_pago,comentarios,id_pago,id_alumno,cantidad_dias,aplica_descuento',
          )
          .eq('id_alumno', idAlumno)
          .eq('user_id', userId);

      if (anio != null) {
        if (mes != null) {
          final startOfMonth = '$anio-${mes.toString().padLeft(2, '0')}-01';
          // Calculamos el último día del mes
          final lastDay = DateTime(anio, mes + 1, 0).day;
          final endOfMonth =
              '$anio-${mes.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';

          query = query
              .gte('"Fecha_de_pago"', startOfMonth)
              .lte('"Fecha_de_pago"', endOfMonth);
        } else {
          final startOfYear = '$anio-01-01';
          final endOfYear = '$anio-12-31';

          query = query
              .gte('"Fecha_de_pago"', startOfYear)
              .lte('"Fecha_de_pago"', endOfYear);
        }
      }

      final response = await query.order('"Fecha_de_pago"', ascending: false);

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

  @override
  Future<void> updatePago(Pago pago) async {
    try {
      await supabaseClient
          .from('Pagos')
          .update({
            'Fecha_de_pago': pago.fechaDePago.toIso8601String(),
            'monto': pago.monto,
            'medio_de_pago': pago.medioDePago,
            'comentarios': pago.comentarios,
            'cantidad_dias': pago.cantidadDias,
            'aplica_descuento': pago.aplicaDescuento,
          })
          .eq('id_pago', pago.idPago);
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar pago: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> deletePago(String idPago) async {
    try {
      await supabaseClient.from('Pagos').delete().eq('id_pago', idPago);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar pago: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
