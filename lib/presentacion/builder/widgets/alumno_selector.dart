import 'package:flutter/material.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';

class AlumnoSelector extends StatelessWidget {
  final List<Alumno> alumnos;
  final Alumno? alumnoSeleccionado;
  final ValueChanged<Alumno?> onAlumnoChanged;

  const AlumnoSelector({
    super.key,
    required this.alumnos,
    required this.alumnoSeleccionado,
    required this.onAlumnoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<Alumno>(
      initialSelection: alumnoSeleccionado,
      hintText: 'Seleccionar alumno...',
      expandedInsets: EdgeInsets.zero, // ocupa el ancho disponible
      enableFilter: true,             // habilita búsqueda por texto
      enableSearch: true,
      onSelected: onAlumnoChanged,
      dropdownMenuEntries: alumnos.map((alumno) {
        return DropdownMenuEntry<Alumno>(
          value: alumno,
          label: alumno.nombreCompleto,
        );
      }).toList(),
    );
  }
}