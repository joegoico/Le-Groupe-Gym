class Precio {
  final String? idPrecio;
  final int cantidadDias;
  final int valor;

  Precio({this.idPrecio, required this.cantidadDias, required this.valor});

  factory Precio.fromMap(Map<String, dynamic> map) {
    return Precio(
      idPrecio: map['id_precio'] as String?,
      cantidadDias: map['cantidad_dias'] as int,
      valor: map['valor'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {'cantidad_dias': cantidadDias, 'valor': valor};
  }

  Precio copyWith({String? idPrecio, int? cantidadDias, int? valor}) {
    return Precio(
      idPrecio: idPrecio ?? this.idPrecio,
      cantidadDias: cantidadDias ?? this.cantidadDias,
      valor: valor ?? this.valor,
    );
  }
}
