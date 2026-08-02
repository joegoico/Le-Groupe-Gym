import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';

abstract class DescuentoRepository {
  Future<List<Descuento>> getDescuentos();
  Future<String> createDescuento(Descuento descuento);
  Future<void> updateDescuento(Descuento descuento);
  Future<void> deleteDescuento(String id);
}

class SupabaseDescuentoRepository implements DescuentoRepository {
  final SupabaseClient supabaseClient;

  SupabaseDescuentoRepository({required this.supabaseClient});

  @override
  Future<List<Descuento>> getDescuentos() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Descuentos')
          .select()
          .eq('user_id', userId);

      return (response as List<dynamic>)
          .map((json) => Descuento.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener descuentos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<String> createDescuento(Descuento descuento) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Descuentos')
          .insert({...descuento.toMap(), 'user_id': userId})
          .select('id')
          .single();

      return response['id'] as String;
    } on PostgrestException catch (e) {
      if (e.message.contains('check_descuento_valor')) {
        throw Exception('El valor del descuento debe ser mayor a 0');
      }
      throw Exception('Error al crear descuento: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> updateDescuento(Descuento descuento) async {
    try {
      await supabaseClient
          .from('Descuentos')
          .update(descuento.toMap())
          .eq('id', descuento.id!);
    } on PostgrestException catch (e) {
      if (e.message.contains('check_descuento_valor')) {
        throw Exception('El valor del descuento debe ser mayor a 0');
      }
      throw Exception('Error al actualizar descuento: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> deleteDescuento(String id) async {
    try {
      await supabaseClient.from('Descuentos').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar descuento: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
