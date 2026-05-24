import 'category_exercise_model.dart';

class Ejercicio {
  final int idEjercicio;
  final String nombre;
  final List<CategoriaEjercicio> categorias;

  Ejercicio({
    required this.idEjercicio,
    required this.nombre,
    required this.categorias,
  });

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    // Extraemos la lista de la relación muchos a muchos
    final relList = json['Rel_Ejercicio_Categoria'] as List? ?? [];
    
    // Mapeamos cada elemento interno hacia nuestro modelo de CategoriaEjercicio
    final List<CategoriaEjercicio> cats = relList.map((rel) {
      final jsonCategoria = rel['Categorias_Ejercicio'] as Map<String, dynamic>;
      return CategoriaEjercicio.fromJson(jsonCategoria);
    }).toList();

    return Ejercicio(
      idEjercicio: json['id_ejercicio'] as int,
      nombre: json['nombre'] as String,
      categorias: cats,
    );
  }

  // Clona la instancia para mutar estados en la UI de forma segura
  Ejercicio copyWith({
    int? idEjercicio,
    String? nombre,
    List<CategoriaEjercicio>? categorias,
  }) {
    return Ejercicio(
      idEjercicio: idEjercicio ?? this.idEjercicio,
      nombre: nombre ?? this.nombre,
      categorias: categorias ?? this.categorias,
    );
  }

  // Exporta solo la data del ejercicio para la tabla principal en Supabase
  Map<String, dynamic> toMap() {
    return {
      'id_ejercicio': idEjercicio,
      'nombre': nombre,
      // No incluimos 'categorias' porque eso se gestiona insertando en Rel_Ejercicio_Categoria
    };
  }
}