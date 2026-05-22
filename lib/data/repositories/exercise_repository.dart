import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';

class ExerciseRepository {
  final SupabaseClient supabaseClient;

  ExerciseRepository({required this.supabaseClient});

  Future<List<Ejercicio>> getExercises() async {
    try {
      // Dejamos la query limpia tal cual funciona en producción
      final response = await supabaseClient
          .from('Ejercicios')
          .select('*, Rel_Ejercicio_Categoria(Categorias_Ejercicio(*))');

      // Forzamos el casteo correcto a List
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Ejercicio.fromJson(json as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener ejercicios desde el repositorio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado en el repositorio: $e');
    }
  }
}