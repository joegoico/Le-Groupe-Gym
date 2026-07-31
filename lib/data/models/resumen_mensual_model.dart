class ResumenMensual {
  final int mes;
  final int anio;
  final num totalEfectivo;
  final num totalTransferencia;
  final num total;

  ResumenMensual({
    required this.mes,
    required this.anio,
    required this.totalEfectivo,
    required this.totalTransferencia,
    required this.total,
  });

  /// Construye un ResumenMensual desde la respuesta de la RPC `get_resumenes_mensuales`.
  factory ResumenMensual.fromRpc(Map<String, dynamic> map) {
    return ResumenMensual(
      anio: (map['anio'] as num).toInt(),
      mes: (map['mes'] as num).toInt(),
      totalEfectivo: (map['total_efectivo'] as num?) ?? 0,
      totalTransferencia: (map['total_transferencia'] as num?) ?? 0,
      total: (map['total'] as num?) ?? 0,
    );
  }

  String get titulo {
    const meses = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${meses[mes]} $anio';
  }
}
