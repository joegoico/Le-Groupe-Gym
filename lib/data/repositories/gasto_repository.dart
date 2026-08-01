import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:le_groupe_gym/data/models/gasto_model.dart';

abstract class GastoRepository {
  Future<List<Gasto>> getGastosPorPeriodo({required DateTime desde, required DateTime hasta});
  Future<String> createGasto(Gasto gasto);
  Future<void> updateGasto(Gasto gasto);
  Future<void> deleteGasto(String idGasto);
}

class SupabaseGastoRepository implements GastoRepository {
  final SupabaseClient supabaseClient;

  SupabaseGastoRepository({required this.supabaseClient});

  @override
  Future<List<Gasto>> getGastosPorPeriodo({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      final response = await supabaseClient
          .from('Gastos')
          .select('*, Categorias_gastos(*)')
          .eq('user_id', userId)
          .gte('fecha', desde.toIso8601String().split('T')[0])
          .lte('fecha', hasta.toIso8601String().split('T')[0])
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Gasto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener gastos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<String> createGasto(Gasto gasto) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      final response = await supabaseClient
          .from('Gastos')
          .insert({...gasto.toMap(), 'user_id': userId})
          .select('id_gasto')
          .single();

      return response['id_gasto'] as String;
    } on PostgrestException catch (e) {
      throw Exception('Error al crear gasto: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> updateGasto(Gasto gasto) async {
    try {
      if (gasto.idGasto == null) throw Exception('El gasto no tiene ID');
      await supabaseClient
          .from('Gastos')
          .update(gasto.toMap())
          .eq('id_gasto', gasto.idGasto!);
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar gasto: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> deleteGasto(String idGasto) async {
    try {
      await supabaseClient
          .from('Gastos')
          .delete()
          .eq('id_gasto', idGasto);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar gasto: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
