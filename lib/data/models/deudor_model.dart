class Deudor {
  final String idDeudor;
  final String nombre;
  final String apellido;
  final int diasAdeudados;
  final DateTime createdAt;

  Deudor({
    required this.idDeudor,
    required this.nombre,
    required this.apellido,
    required this.diasAdeudados,
    required this.createdAt,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory Deudor.fromMap(Map<String, dynamic> map) {
    return Deudor(
      idDeudor: map['id_deudor'] as String,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
      diasAdeudados: map['dias_adeudados'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_deudor': idDeudor,
      'nombre': nombre,
      'apellido': apellido,
      'dias_adeudados': diasAdeudados,
    };
  }
}
