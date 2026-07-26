import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:le_groupe_gym/data/models/deudor_model.dart';

abstract class DeudorRepository {
  Future<List<Deudor>> getDeudores();
  Future<void> eliminarDeudor(String idDeudor);
}

class SupabaseDeudorRepository implements DeudorRepository {
  final SupabaseClient supabaseClient;

  SupabaseDeudorRepository({required this.supabaseClient});

  @override
  Future<List<Deudor>> getDeudores() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      final response = await supabaseClient
          .from('Deudor')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Deudor.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener deudores: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> eliminarDeudor(String idDeudor) async {
    try {
      await supabaseClient.from('Deudor').delete().eq('id_deudor', idDeudor);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar deudor: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
