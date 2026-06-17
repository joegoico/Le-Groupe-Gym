// lib/data/models/paginated_exercises_model.dart
import 'package:le_groupe_gym/data/models/exercise_model.dart';

class PaginatedExercises {
  final List<Ejercicio> ejercicios;
  final bool hayMas;
  final int page;

  const PaginatedExercises({
    required this.ejercicios,
    required this.hayMas,
    required this.page,
  });
}
