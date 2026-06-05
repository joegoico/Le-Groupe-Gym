class CategoriaEjercicio {
  final int idCategoria;
  final String nombre;
  final String tipo;
  final int? idCategoriaPadre;

  CategoriaEjercicio({
    required this.idCategoria,
    required this.nombre,
    required this.tipo,
    this.idCategoriaPadre,
  });
  @override
  bool operator ==(Object other) =>
      other is CategoriaEjercicio && other.idCategoria == idCategoria;

  @override
  int get hashCode => idCategoria.hashCode;

  factory CategoriaEjercicio.fromJson(Map<String, dynamic> json) {
    return CategoriaEjercicio(
      idCategoria: json['id_categoria'] as int,
      nombre: json['nombre'] as String,
      tipo: json['tipo'] as String,
      idCategoriaPadre: json['id_categoria_padre'] as int?,
    );
  }

  // Clona la instancia controlando la mutación de estados
  CategoriaEjercicio copyWith({
    int? idCategoria,
    String? nombre,
    String? tipo,
    int? idCategoriaPadre,
  }) {
    return CategoriaEjercicio(
      idCategoria: idCategoria ?? this.idCategoria,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      idCategoriaPadre: idCategoriaPadre ?? this.idCategoriaPadre,
    );
  }

  // Exporta la estructura con llaves snake_case para Supabase
  Map<String, dynamic> toMap() {
    return {
      'id_categoria': idCategoria,
      'nombre': nombre,
      'tipo': tipo,
      if (idCategoriaPadre != null) 'id_categoria_padre': idCategoriaPadre,
    };
  }
}
