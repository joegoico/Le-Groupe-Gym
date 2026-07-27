class Pago {
  final String idPago;
  final String idAlumno;
  final DateTime fechaDePago;
  final double monto;
  final String medioDePago;
  final String? comentarios;
  final int cantidadDias;
  final bool aplicaDescuento;

  Pago({
    required this.idPago,
    required this.idAlumno,
    required this.fechaDePago,
    required this.monto,
    required this.medioDePago,
    this.comentarios,
    required this.cantidadDias,
    this.aplicaDescuento = false,
  });

  factory Pago.fromMap(Map<String, dynamic> map) {
    return Pago(
      idPago: map['id_pago'] as String,
      idAlumno: map['id_alumno'] as String,
      fechaDePago: DateTime.parse(map['Fecha_de_pago'] as String),
      monto: (map['monto'] as num).toDouble(),
      medioDePago: map['medio_de_pago'] as String,
      comentarios: map['comentarios'] as String?,
      cantidadDias: map['cantidad_dias'] as int,
      aplicaDescuento: map['aplica_descuento'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_alumno': idAlumno,
      'Fecha_de_pago':
          "${fechaDePago.year.toString().padLeft(4, '0')}-${fechaDePago.month.toString().padLeft(2, '0')}-${fechaDePago.day.toString().padLeft(2, '0')}",
      'monto': monto,
      'medio_de_pago': medioDePago,
      'comentarios': comentarios,
      'cantidad_dias': cantidadDias,
      'aplica_descuento': aplicaDescuento,
    };
  }
}
