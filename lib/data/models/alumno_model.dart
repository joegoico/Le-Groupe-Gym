class Alumno {
  final String idAlumno;
  final String nombre;
  final String apellido;
  final String? mail;

  Alumno({
    required this.idAlumno,
    required this.nombre,
    required this.apellido,
    this.mail,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory Alumno.fromMap(Map<String, dynamic> map) {
    return Alumno(
      idAlumno: map['id_alumno'] as String,
      nombre: map['Nombre'] as String,
      apellido: map['Apellido'] as String,
      mail: map['Mail'] as String?,
    );
  }
}
