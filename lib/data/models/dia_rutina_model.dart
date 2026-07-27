import 'package:le_groupe_gym/data/models/routine_block_model.dart';

class DiaRutina {
  final int? idDia;
  final String nombre;
  final int orden;
  final List<BloqueRutina> bloques;
  final String? internalId;

  DiaRutina({
    this.idDia,
    required this.nombre,
    required this.orden,
    List<BloqueRutina>? bloques,
    this.internalId,
  }) : bloques = bloques ?? [];

  bool get estaVacio => bloques.isEmpty || bloques.every((b) => b.estaVacio);

  DiaRutina copyWith({
    int? idDia,
    String? nombre,
    int? orden,
    List<BloqueRutina>? bloques,
    String? internalId,
  }) {
    return DiaRutina(
      idDia: idDia ?? this.idDia,
      nombre: nombre ?? this.nombre,
      orden: orden ?? this.orden,
      bloques: bloques ?? this.bloques,
      internalId: internalId ?? this.internalId,
    );
  }

  Map<String, dynamic> toMap({required int idRutina}) {
    return {'nombre_dia': nombre, 'orden': orden, 'id_rutina': idRutina};
  }

  factory DiaRutina.fromMap(
    Map<String, dynamic> map, {
    List<BloqueRutina>? bloques,
  }) {
    return DiaRutina(
      idDia: map['id_dia'] as int?,
      nombre: map['nombre_dia'] as String,
      orden: map['orden'] as int,
      bloques: bloques ?? [],
    );
  }
}
