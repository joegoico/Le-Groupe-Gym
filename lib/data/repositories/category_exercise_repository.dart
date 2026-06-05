import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ICategoryExerciseRepository {
  Future<List<CategoriaEjercicio>> getCategories();
}

class CategoryExerciseRepository implements ICategoryExerciseRepository {
  final SupabaseClient supabaseClient;

  CategoryExerciseRepository({required this.supabaseClient});

  @override
  Future<List<CategoriaEjercicio>> getCategories() async {
    return [];
  }
}
