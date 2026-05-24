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

  // Clona la instancia controlando la mutación de estados
  CategoriaEjercicio copyWith({
    int? idCategoria,
    String? nombre,
    String? tipo,
  }) {
    return CategoriaEjercicio(
      idCategoria: idCategoria ?? this.idCategoria,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
    );
  }

  // Exporta la estructura con llaves snake_case para Supabase
  Map<String, dynamic> toMap() {
    return {
      'id_categoria': idCategoria,
      'nombre': nombre,
      'tipo': tipo,
    };
  }
}