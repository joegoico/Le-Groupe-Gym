class Alumno {
  final String idAlumno;
  final String nombre;
  final String apellido;
  final String? mail;
  final bool aplicaDescuento;

  Alumno({
    required this.idAlumno,
    required this.nombre,
    required this.apellido,
    this.mail,
    required this.aplicaDescuento,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory Alumno.fromMap(Map<String, dynamic> map) {
    return Alumno(
      idAlumno: map['id_alumno'] as String,
      nombre: map['Nombre'] as String,
      apellido: map['Apellido'] as String,
      mail: map['Mail'] as String?,
      aplicaDescuento: map['aplica_descuento'] as bool,
    );
  }
}
