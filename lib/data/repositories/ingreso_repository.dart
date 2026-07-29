import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:le_groupe_gym/data/models/ingreso_model.dart';

abstract class IngresoRepository {
  Future<List<Ingreso>> getIngresos();
  Future<String> createIngreso(Ingreso ingreso);
  Future<List<Ingreso>> getIngresosPorPeriodo({
    required DateTime desde,
    required DateTime hasta,
  });
  Future<List<Ingreso>> getIngresosPorFecha({required DateTime fecha});
}

class SupabaseIngresoRepository implements IngresoRepository {
  final SupabaseClient supabaseClient;

  SupabaseIngresoRepository({required this.supabaseClient});

  @override
  Future<List<Ingreso>> getIngresos() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      final response = await supabaseClient
          .from('Ingresos')
          .select()
          .eq('user_id', userId)
          .order('fecha_ingreso', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Ingreso.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener ingresos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<String> createIngreso(Ingreso ingreso) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      final response = await supabaseClient
          .from('Ingresos')
          .insert({...ingreso.toMap(), 'user_id': userId})
          .select('id_ingreso')
          .single();

      return response['id_ingreso'] as String;
    } on PostgrestException catch (e) {
      throw Exception('Error al crear ingreso: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<List<Ingreso>> getIngresosPorPeriodo({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      final response = await supabaseClient
          .from('Ingresos')
          .select()
          .eq('user_id', userId)
          .gte('fecha_ingreso', desde.toIso8601String().split('T')[0])
          .lte('fecha_ingreso', hasta.toIso8601String().split('T')[0])
          .order('fecha_ingreso', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Ingreso.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener ingresos por período: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<List<Ingreso>> getIngresosPorFecha({required DateTime fecha}) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      final response = await supabaseClient
          .from('Ingresos')
          .select()
          .eq('user_id', userId)
          .eq('fecha_ingreso', fecha.toIso8601String().split('T')[0])
          .order('fecha_ingreso', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Ingreso.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener ingresos por fecha: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
