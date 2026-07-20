class Descuento {
  final String? id;
  final int valor;

  Descuento({this.id, required this.valor});

  factory Descuento.fromMap(Map<String, dynamic> map) {
    return Descuento(id: map['id'] as String?, valor: map['Valor'] as int);
  }

  Map<String, dynamic> toMap() {
    return {'Valor': valor};
  }

  Descuento copyWith({String? id, int? valor}) {
    return Descuento(id: id ?? this.id, valor: valor ?? this.valor);
  }
}
