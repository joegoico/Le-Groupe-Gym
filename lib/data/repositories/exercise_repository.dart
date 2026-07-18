import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';

abstract class ExerciseRepository {
  Future<List<Ejercicio>> getExercises();
  Future<int> createExercise({
    required String nombre,
    required List<int> categoriaIds,
  });
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
      throw Exception(
        'Error al obtener ejercicios: ${e.message} (code: ${e.code})',
      );
    } on Exception catch (e) {
      throw Exception('Error de red al obtener ejercicios: $e');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<int> createExercise({
    required String nombre,
    required List<int> categoriaIds,
  }) async {
    try {
      // Paso 1 — insertar el ejercicio
      final response = await supabaseClient
          .from('Ejercicios')
          .insert({'nombre': nombre})
          .select('id_ejercicio')
          .single();

      final idEjercicio = response['id_ejercicio'] as int;

      // Paso 2 — insertar las relaciones con categorías
      if (categoriaIds.isNotEmpty) {
        final relaciones = categoriaIds
            .map(
              (idCat) => {'id_ejercicio': idEjercicio, 'id_categoria': idCat},
            )
            .toList();

        await supabaseClient.from('Rel_Ejercicio_Categoria').insert(relaciones);
      }

      return idEjercicio;
    } on PostgrestException catch (e) {
      throw Exception('Error al crear ejercicio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al crear ejercicio: $e');
    }
  }
}
