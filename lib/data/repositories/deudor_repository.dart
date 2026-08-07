import 'package:le_groupe_gym/core/app_failure.dart';
import 'package:le_groupe_gym/core/database_error_translator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/deudor_model.dart';

abstract class DeudorRepository {
  Future<List<Deudor>> getDeudores();
}

class SupabaseDeudorRepository implements DeudorRepository {
  final SupabaseClient supabaseClient;

  SupabaseDeudorRepository({required this.supabaseClient});

  @override
  Future<List<Deudor>> getDeudores() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw const SessionFailure('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Deudor')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Deudor.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    } catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    }
  }

  Future<void> eliminarDeudor(String idDeudor) async {
    try {
      await supabaseClient.from('Deudor').delete().eq('id_deudor', idDeudor);
    } on PostgrestException catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    } catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    }
  }
}
