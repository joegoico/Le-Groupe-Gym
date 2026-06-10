import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/data/repositories/exercise_repository.dart';

class MockExerciseRepository implements ExerciseRepository {
  final List<Ejercicio> _exercises = [
    // Pecho (5)
    Ejercicio(idEjercicio: 1, nombre: 'Press de Banca Plano', categorias: [
      CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
      CategoriaEjercicio(idCategoria: 10, nombre: 'Pectoral Mayor', tipo: 'subgrupo'),
    ]),
    Ejercicio(idEjercicio: 2, nombre: 'Press de Banca Inclinado', categorias: [
      CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
      CategoriaEjercicio(idCategoria: 10, nombre: 'Pectoral Mayor', tipo: 'subgrupo'),
    ]),
    Ejercicio(idEjercicio: 3, nombre: 'Cruces de Polea', categorias: [
      CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
      CategoriaEjercicio(idCategoria: 12, nombre: 'Fibras Inferiores', tipo: 'subgrupo'),
    ]),
    Ejercicio(idEjercicio: 4, nombre: 'Aperturas con Mancuerna', categorias: [
      CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
      CategoriaEjercicio(idCategoria: 10, nombre: 'Pectoral Mayor', tipo: 'subgrupo'),
    ]),
    Ejercicio(idEjercicio: 5, nombre: 'Push Ups', categorias: [
      CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
    ]),
    // Espalda (5)
    Ejercicio(idEjercicio: 6, nombre: 'Dominadas', categorias: [
      CategoriaEjercicio(idCategoria: 3, nombre: 'Espalda', tipo: 'grupo_muscular'),
      CategoriaEjercicio(idCategoria: 13, nombre: 'Dorsal Ancho', tipo: 'subgrupo'),
    ]),
    Ejercicio(idEjercicio: 7, nombre: 'Remo con Barra', categorias: [
      CategoriaEjercicio(idCategoria: 3, nombre: 'Espalda', tipo: 'grupo_muscular'),
      CategoriaEjercicio(idCategoria: 13, nombre: 'Dorsal Ancho', tipo: 'subgrupo'),
    ]),
    Ejercicio(idEjercicio: 8, nombre: 'Remo con Mancuerna', categorias: [
      CategoriaEjercicio(idCategoria: 3, nombre: 'Espalda', tipo: 'grupo_muscular'),
    ]),
    Ejercicio(idEjercicio: 9, nombre: 'Pullover', categorias: [
      CategoriaEjercicio(idCategoria: 3, nombre: 'Espalda', tipo: 'grupo_muscular'),
    ]),
    Ejercicio(idEjercicio: 10, nombre: 'Jalón al Pecho', categorias: [
      CategoriaEjercicio(idCategoria: 3, nombre: 'Espalda', tipo: 'grupo_muscular'),
      CategoriaEjercicio(idCategoria: 13, nombre: 'Dorsal Ancho', tipo: 'subgrupo'),
    ]),
    // Piernas (5)
    Ejercicio(idEjercicio: 11, nombre: 'Sentadilla Libre', categorias: [
      CategoriaEjercicio(idCategoria: 2, nombre: 'Piernas', tipo: 'grupo_muscular'),
      CategoriaEjercicio(idCategoria: 11, nombre: 'Cuádriceps', tipo: 'subgrupo'),
    ]),
    Ejercicio(idEjercicio: 12, nombre: 'Prensa 45°', categorias: [
      CategoriaEjercicio(idCategoria: 2, nombre: 'Piernas', tipo: 'grupo_muscular'),
      CategoriaEjercicio(idCategoria: 11, nombre: 'Cuádriceps', tipo: 'subgrupo'),
    ]),
    Ejercicio(idEjercicio: 13, nombre: 'Peso Muerto Rumano', categorias: [
      CategoriaEjercicio(idCategoria: 2, nombre: 'Piernas', tipo: 'grupo_muscular'),
      CategoriaEjercicio(idCategoria: 14, nombre: 'Isquiotibiales', tipo: 'subgrupo'),
    ]),
    Ejercicio(idEjercicio: 14, nombre: 'Extensiones de Cuádriceps', categorias: [
      CategoriaEjercicio(idCategoria: 2, nombre: 'Piernas', tipo: 'grupo_muscular'),
      CategoriaEjercicio(idCategoria: 11, nombre: 'Cuádriceps', tipo: 'subgrupo'),
    ]),
    Ejercicio(idEjercicio: 15, nombre: 'Curl Femoral', categorias: [
      CategoriaEjercicio(idCategoria: 2, nombre: 'Piernas', tipo: 'grupo_muscular'),
      CategoriaEjercicio(idCategoria: 14, nombre: 'Isquiotibiales', tipo: 'subgrupo'),
    ]),
    // Hombros (5)
    Ejercicio(idEjercicio: 16, nombre: 'Press Militar', categorias: [
      CategoriaEjercicio(idCategoria: 4, nombre: 'Hombros', tipo: 'grupo_muscular'),
    ]),
    Ejercicio(idEjercicio: 17, nombre: 'Elevaciones Laterales', categorias: [
      CategoriaEjercicio(idCategoria: 4, nombre: 'Hombros', tipo: 'grupo_muscular'),
    ]),
    Ejercicio(idEjercicio: 18, nombre: 'Elevaciones Frontales', categorias: [
      CategoriaEjercicio(idCategoria: 4, nombre: 'Hombros', tipo: 'grupo_muscular'),
    ]),
    Ejercicio(idEjercicio: 19, nombre: 'Pájaros', categorias: [
      CategoriaEjercicio(idCategoria: 4, nombre: 'Hombros', tipo: 'grupo_muscular'),
    ]),
    Ejercicio(idEjercicio: 20, nombre: 'Face Pull', categorias: [
      CategoriaEjercicio(idCategoria: 4, nombre: 'Hombros', tipo: 'grupo_muscular'),
    ]),
  ];

  @override
  Future<List<Ejercicio>> getExercises() async {
    return List.unmodifiable(_exercises);
  }

  @override
  Future<List<Ejercicio>> searchExercises({
    String? query,
    List<String>? muscleGroups,
    List<String>? subgroups,
    int limit = 15,
    int offset = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    var filtered = _exercises.where((e) {
      final matchesSearch = query == null ||
          query.isEmpty ||
          e.nombre.toLowerCase().contains(query.toLowerCase());

      final matchesMuscleGroup = muscleGroups == null ||
          muscleGroups.isEmpty ||
          e.categorias.any(
            (c) => c.tipo == 'grupo_muscular' && muscleGroups.contains(c.nombre),
          );

      final matchesSubgroup = subgroups == null ||
          subgroups.isEmpty ||
          e.categorias.any(
            (c) => c.tipo == 'subgrupo' && subgroups.contains(c.nombre),
          );

      return matchesSearch && matchesMuscleGroup && matchesSubgroup;
    }).toList();

    // Apply pagination
    if (offset >= filtered.length) return [];
    final end = (offset + limit).clamp(0, filtered.length);
    return filtered.sublist(offset, end);
  }

  @override
  Future<int> createExercise({
    required String nombre,
    required List<int> categoriaIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 99; // id mock
  }
}
