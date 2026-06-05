import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';
import 'package:le_groupe_gym/data/repositories/routine_repository.dart';
import 'package:le_groupe_gym/data/repositories/alumno_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/repositories/category_exercise_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return SupabaseExerciseRepository(supabaseClient: Supabase.instance.client);
});

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return SupabaseRoutineRepository(supabaseClient: Supabase.instance.client);
});

final alumnoRepositoryProvider = Provider<AlumnoRepository>((ref) {
  return SupabaseAlumnoRepository(supabaseClient: Supabase.instance.client);
});

final categoryExerciseRepositoryProvider = Provider<CategoryExerciseRepository>(
  (ref) {
    return CategoryExerciseRepository(supabaseClient: Supabase.instance.client);
  },
);
