import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';

abstract class ExerciseRepository {
  Future<List<Ejercicio>> getExercises();
}

class SupabaseExerciseRepository implements ExerciseRepository {
  final SupabaseClient supabaseClient;

  SupabaseExerciseRepository({required this.supabaseClient});

  @override
  Future<List<Ejercicio>> getExercises() async {
    try {
      final response = await supabaseClient
          .from('Ejercicios')
          .select('*, Rel_Ejercicio_Categoria(Categorias_Ejercicio(*))');

      return (response as List<dynamic>)
          .map((json) => Ejercicio.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener ejercicios: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}