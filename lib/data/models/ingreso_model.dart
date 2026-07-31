class Ingreso {
  final String? idIngreso;
  final DateTime fechaIngreso;
  final String concepto;
  final num monto;
  final String? medioDePago;
  final String? idPago;

  Ingreso({
    this.idIngreso,
    required this.fechaIngreso,
    required this.concepto,
    required this.monto,
    this.medioDePago,
    this.idPago,
  });

  factory Ingreso.fromMap(Map<String, dynamic> map) {
    return Ingreso(
      idIngreso: map['id_ingreso'] as String?,
      fechaIngreso: DateTime.parse(map['fecha_ingreso'] as String),
      concepto: map['concepto'] as String,
      monto: map['monto'] as num,
      medioDePago: map['medio_de_pago'] as String?,
      idPago: map['id_pago'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fecha_ingreso': fechaIngreso.toIso8601String().split('T')[0],
      'concepto': concepto,
      'monto': monto,
      if (medioDePago != null) 'medio_de_pago': medioDePago,
      if (idPago != null) 'id_pago': idPago,
    };
  }

  Ingreso copyWith({
    String? idIngreso,
    DateTime? fechaIngreso,
    String? concepto,
    num? monto,
    String? medioDePago,
    String? idPago,
  }) {
    return Ingreso(
      idIngreso: idIngreso ?? this.idIngreso,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      concepto: concepto ?? this.concepto,
      monto: monto ?? this.monto,
      medioDePago: medioDePago ?? this.medioDePago,
      idPago: idPago ?? this.idPago,
    );
  }
}
