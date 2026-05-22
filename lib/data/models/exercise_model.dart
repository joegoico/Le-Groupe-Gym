class CategoriaEjercicio {
  final int idCategoria;
  final String nombre;
  final String tipo;

  CategoriaEjercicio({
    required this.idCategoria,
    required this.nombre,
    required this.tipo,
  });

  factory CategoriaEjercicio.fromJson(Map<String, dynamic> json) {
    return CategoriaEjercicio(
      idCategoria: json['id_categoria'] as int,
      nombre: json['nombre'] as String,
      tipo: json['tipo'] as String,
    );
  }
}

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
}