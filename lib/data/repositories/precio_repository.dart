import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';

abstract class PrecioRepository {
  Future<List<Precio>> getPrecios();
  Future<String> createPrecio(Precio precio);
  Future<void> updatePrecio(Precio precio);
  Future<void> deletePrecio(String idPrecio);
}

class SupabasePrecioRepository implements PrecioRepository {
  final SupabaseClient supabaseClient;

  SupabasePrecioRepository({required this.supabaseClient});

  @override
  Future<List<Precio>> getPrecios() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Precios')
          .select()
          .eq('user_id', userId)
          .order('cantidad_dias');

      return (response as List<dynamic>)
          .map((json) => Precio.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener precios: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<String> createPrecio(Precio precio) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Precios')
          .insert({...precio.toMap(), 'user_id': userId})
          .select('id_precio')
          .single();

      return response['id_precio'] as String;
    } on PostgrestException catch (e) {
      if (e.message.contains('check_precio_dias')) {
        throw Exception('La cantidad de días debe estar entre 1 y 7');
      }
      if (e.message.contains('check_precio_valor')) {
        throw Exception('El valor debe ser mayor a 0');
      }
      throw Exception('Error al crear precio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> updatePrecio(Precio precio) async {
    try {
      await supabaseClient
          .from('Precios')
          .update(precio.toMap())
          .eq('id_precio', precio.idPrecio!);
    } on PostgrestException catch (e) {
      if (e.message.contains('check_precio_dias')) {
        throw Exception('La cantidad de días debe estar entre 1 y 7');
      }
      if (e.message.contains('check_precio_valor')) {
        throw Exception('El valor debe ser mayor a 0');
      }
      throw Exception('Error al actualizar precio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> deletePrecio(String idPrecio) async {
    try {
      await supabaseClient.from('Precios').delete().eq('id_precio', idPrecio);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar precio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
