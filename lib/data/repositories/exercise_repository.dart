import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';

abstract class ExerciseRepository {
  Future<List<Ejercicio>> getExercises();
}

class MockExerciseRepository implements ExerciseRepository {
  @override
  Future<List<Ejercicio>> getExercises() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Ejercicio(
        idEjercicio: 1,
        nombre: 'Press de Banca Plano',
        categorias: [
          CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
          CategoriaEjercicio(idCategoria: 10, nombre: 'Pectoral Mayor', tipo: 'subgrupo'),
        ],
      ),
      Ejercicio(
        idEjercicio: 2,
        nombre: 'Sentadilla Libre',
        categorias: [
          CategoriaEjercicio(idCategoria: 2, nombre: 'Piernas', tipo: 'grupo_muscular'),
          CategoriaEjercicio(idCategoria: 11, nombre: 'Cuádriceps', tipo: 'subgrupo'),
        ],
      ),
      Ejercicio(
        idEjercicio: 3,
        nombre: 'Cruces de Polea Alta',
        categorias: [
          CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
          CategoriaEjercicio(idCategoria: 12, nombre: 'Fibras Inferiores', tipo: 'subgrupo'),
        ],
      ),
      Ejercicio(
        idEjercicio: 4,
        nombre: 'Dominadas',
        categorias: [
          CategoriaEjercicio(idCategoria: 3, nombre: 'Espalda', tipo: 'grupo_muscular'),
          CategoriaEjercicio(idCategoria: 13, nombre: 'Dorsal Ancho', tipo: 'subgrupo'),
        ],
      ),
      Ejercicio(
        idEjercicio: 5,
        nombre: 'Plancha Abdominal',
        categorias: [
          CategoriaEjercicio(idCategoria: 4, nombre: 'Core / Abdomen', tipo: 'grupo_muscular'),
          CategoriaEjercicio(idCategoria: 14, nombre: 'Abdomen Recto', tipo: 'subgrupo'),
        ],
      ),
      Ejercicio(
        idEjercicio: 6,
        nombre: 'Vuelos Laterales',
        categorias: [
          CategoriaEjercicio(idCategoria: 5, nombre: 'Hombros', tipo: 'grupo_muscular'),
          CategoriaEjercicio(idCategoria: 15, nombre: 'Deltoides Lateral', tipo: 'subgrupo'),
        ],
      ),
      Ejercicio(
        idEjercicio: 7,
        nombre: 'Press Militar con Mancuernas',
        categorias: [
          CategoriaEjercicio(idCategoria: 5, nombre: 'Hombros', tipo: 'grupo_muscular'),
          CategoriaEjercicio(idCategoria: 16, nombre: 'Deltoides Anterior', tipo: 'subgrupo'),
        ],
      ),
      Ejercicio(
        idEjercicio: 8,
        nombre: 'Curl de Biceps con Barra',
        categorias: [
          CategoriaEjercicio(idCategoria: 6, nombre: 'Biceps', tipo: 'grupo_muscular'),
          CategoriaEjercicio(idCategoria: 17, nombre: 'Bíceps Braquial', tipo: 'subgrupo'),
        ],
      ),
      Ejercicio(
        idEjercicio: 9,
        nombre: 'Extensión de Triceps en Polea',
        categorias: [
          CategoriaEjercicio(idCategoria: 7, nombre: 'Triceps', tipo: 'grupo_muscular'),
          CategoriaEjercicio(idCategoria: 18, nombre: 'Tríceps Cabeza Larga', tipo: 'subgrupo'),
        ],
      ),
      Ejercicio(
        idEjercicio: 10,
        nombre: 'Peso Muerto Rumano',
        categorias: [
          CategoriaEjercicio(idCategoria: 2, nombre: 'Piernas', tipo: 'grupo_muscular'),
          CategoriaEjercicio(idCategoria: 19, nombre: 'Isquiotibiales', tipo: 'subgrupo'),
        ],
      ),
      Ejercicio(
        idEjercicio: 11,
        nombre: 'Remo con Barra',
        categorias: [
          CategoriaEjercicio(idCategoria: 3, nombre: 'Espalda', tipo: 'grupo_muscular'),
          CategoriaEjercicio(idCategoria: 13, nombre: 'Dorsal Ancho', tipo: 'subgrupo'),
        ],
      ),
      Ejercicio(
        idEjercicio: 12,
        nombre: 'Rueda Abdominal',
        categorias: [
          CategoriaEjercicio(idCategoria: 4, nombre: 'Core / Abdomen', tipo: 'grupo_muscular'),
          CategoriaEjercicio(idCategoria: 14, nombre: 'Abdomen Recto', tipo: 'subgrupo'),
        ],
      ),
    ];
  }
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

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Ejercicio.fromJson(json as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener ejercicios desde el repositorio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado en el repositorio: $e');
    }
  }
}