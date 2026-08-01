class CategoriaGasto {
  final String? idCategoria;
  final String nombre;

  CategoriaGasto({this.idCategoria, required this.nombre});

  factory CategoriaGasto.fromMap(Map<String, dynamic> map) {
    return CategoriaGasto(
      idCategoria: map['id_categoria'] as String?,
      nombre: map['nombre'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'nombre': nombre};
  }

  CategoriaGasto copyWith({String? idCategoria, String? nombre}) {
    return CategoriaGasto(
      idCategoria: idCategoria ?? this.idCategoria,
      nombre: nombre ?? this.nombre,
    );
  }
}
