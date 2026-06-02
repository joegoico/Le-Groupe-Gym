import 'exercise_model.dart';

/// Límite de ejercicios por tarjeta al combinar en superserie.
class LimiteSuperserieException implements Exception {
  final String message;
  const LimiteSuperserieException([
    this.message = 'Una superserie admite como máximo 2 ejercicios.',
  ]);

  @override
  String toString() => message;
}

/// Un ejercicio dentro de una tarjeta de rutina (slot con parámetros propios).
class DetalleEjercicioRutina {
  final Ejercicio ejercicio;
  int series;
  String repeticiones;
  String peso;
  String notas;

  DetalleEjercicioRutina({
    required this.ejercicio,
    this.series = 4,
    this.repeticiones = '10',
    this.peso = '',
    this.notas = '',
  });

  DetalleEjercicioRutina copyWith({
    Ejercicio? ejercicio,
    int? series,
    String? repeticiones,
    String? peso,
    String? notas,
  }) {
    return DetalleEjercicioRutina(
      ejercicio: ejercicio ?? this.ejercicio,
      series: series ?? this.series,
      repeticiones: repeticiones ?? this.repeticiones,
      peso: peso ?? this.peso,
      notas: notas ?? this.notas,
    );
  }
}

class EjercicioRutina {
  static const int maxEjerciciosCombinados = 2;

  final List<DetalleEjercicioRutina> _miembros;

  EjercicioRutina({
    required Ejercicio ejercicio,
    int series = 4,
    String repeticiones = '10',
    String peso = '',
    String notas = '',
  }) : _miembros = [
         DetalleEjercicioRutina(
           ejercicio: ejercicio,
           series: series,
           repeticiones: repeticiones,
           peso: peso,
           notas: notas,
         ),
       ];

  EjercicioRutina._interno(List<DetalleEjercicioRutina> miembros)
    : _miembros = List.of(miembros);

  List<DetalleEjercicioRutina> get miembros => List.unmodifiable(_miembros);

  int get cantidadEjercicios => _miembros.length;

  bool get esSuperserie => _miembros.length > 1;

  /// Primer ejercicio de la tarjeta (compatibilidad con código existente).
  Ejercicio get ejercicio => _miembros.first.ejercicio;

  int get series => _miembros.first.series;
  set series(int value) => _miembros.first.series = value;

  String get repeticiones => _miembros.first.repeticiones;
  set repeticiones(String value) => _miembros.first.repeticiones = value;

  String get peso => _miembros.first.peso;
  set peso(String value) => _miembros.first.peso = value;

  String get notas => _miembros.first.notas;
  set notas(String value) => _miembros.first.notas = value;

  void combinarCon(
    Ejercicio ejercicio, {
    int series = 4,
    String repeticiones = '10',
    String peso = '',
    String notas = '',
  }) {
    if (_miembros.length >= maxEjerciciosCombinados) {
      throw const LimiteSuperserieException();
    }
    _miembros.add(
      DetalleEjercicioRutina(
        ejercicio: ejercicio,
        series: series,
        repeticiones: repeticiones,
        peso: peso,
        notas: notas,
      ),
    );
  }

  void actualizarMiembro(
    int slotIndex, {
    int? series,
    String? repeticiones,
    String? peso,
    String? notas,
  }) {
    if (slotIndex < 0 || slotIndex >= _miembros.length) return;
    final m = _miembros[slotIndex];
    if (series != null) m.series = series;
    if (repeticiones != null) m.repeticiones = repeticiones;
    if (peso != null) m.peso = peso;
    if (notas != null) m.notas = notas;
  }

  EjercicioRutina copyWith({
    Ejercicio? ejercicio,
    int? series,
    String? repeticiones,
    String? peso,
    String? notas,
  }) {
    final actualizados = List<DetalleEjercicioRutina>.from(_miembros);
    actualizados[0] = actualizados[0].copyWith(
      ejercicio: ejercicio,
      series: series,
      repeticiones: repeticiones,
      peso: peso,
      notas: notas,
    );
    return EjercicioRutina._interno(actualizados);
  }

  factory EjercicioRutina.fromMap(
    Map<String, dynamic> map,
    Ejercicio ejercicioBase,
  ) {
    return EjercicioRutina(
      ejercicio: ejercicioBase,
      series: map['series'] as int? ?? 4,
      repeticiones: map['repeticiones'] as String? ?? '10',
      peso: map['peso'] as String? ?? '',
      notas: map['notas'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'series': series,
      'repeticiones': repeticiones,
      'peso': peso,
      'notas': notas,
    };
  }
}
