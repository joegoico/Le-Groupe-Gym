import 'package:le_groupe_gym/data/models/categoria_gasto_model.dart';

class Gasto {
  final String? idGasto;
  final String? descripcion;
  final int monto;
  final DateTime fecha;
  final CategoriaGasto? categoria;

  Gasto({
    this.idGasto,
    this.descripcion,
    required this.monto,
    required this.fecha,
    this.categoria,
  });

  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      idGasto: map['id_gasto'] as String?,
      descripcion: map['descripcion'] as String?,
      monto: map['monto'] as int,
      fecha: DateTime.parse(map['fecha'] as String),
      categoria: map['Categorias_gastos'] != null
          ? CategoriaGasto.fromMap(
              map['Categorias_gastos'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'descripcion': descripcion,
      'monto': monto,
      'fecha': fecha.toIso8601String().split("T")[0],
      'id_categoria': categoria?.idCategoria,
    };
  }

  Gasto copyWith({
    String? idGasto,
    String? descripcion,
    int? monto,
    DateTime? fecha,
    CategoriaGasto? categoria,
  }) {
    return Gasto(
      idGasto: idGasto ?? this.idGasto,
      descripcion: descripcion ?? this.descripcion,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      categoria: categoria ?? this.categoria,
    );
  }
}
