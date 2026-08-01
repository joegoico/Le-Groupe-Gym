import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/categoria_gasto_model.dart';

abstract class CategoriaGastoRepository {
  Future<List<CategoriaGasto>> getCategoriasGastos();
}

class SupabaseCategoriaGastoRepository implements CategoriaGastoRepository {
  final SupabaseClient supabaseClient;

  SupabaseCategoriaGastoRepository({required this.supabaseClient});

  @override
  Future<List<CategoriaGasto>> getCategoriasGastos() async {
    try {
      final response = await supabaseClient
          .from('Categorias_gastos')
          .select()
          .order('nombre', ascending: true);

      return (response as List<dynamic>)
          .map((json) => CategoriaGasto.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener categorías de gastos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
