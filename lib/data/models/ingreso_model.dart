class Ingreso {
  final String? idIngreso;
  final DateTime fechaIngreso;
  final String concepto;
  final num monto;

  Ingreso({
    this.idIngreso,
    required this.fechaIngreso,
    required this.concepto,
    required this.monto,
  });

  factory Ingreso.fromMap(Map<String, dynamic> map) {
    return Ingreso(
      idIngreso: map['id_ingreso'] as String?,
      fechaIngreso: DateTime.parse(map['fecha_ingreso'] as String),
      concepto: map['concepto'] as String,
      monto: map['monto'] as num,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fecha_ingreso': fechaIngreso.toIso8601String().split('T')[0],
      'concepto': concepto,
      'monto': monto,
    };
  }

  Ingreso copyWith({
    String? idIngreso,
    DateTime? fechaIngreso,
    String? concepto,
    num? monto,
  }) {
    return Ingreso(
      idIngreso: idIngreso ?? this.idIngreso,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      concepto: concepto ?? this.concepto,
      monto: monto ?? this.monto,
    );
  }
}
