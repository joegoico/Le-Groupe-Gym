import 'package:le_groupe_gym/data/models/ingreso_model.dart';

class ResumenMensual {
  final int mes;
  final int anio;
  final List<Ingreso> ingresos;

  ResumenMensual({
    required this.mes,
    required this.anio,
    required this.ingresos,
  });

  num get total => ingresos.fold(0, (sum, i) => sum + i.monto);

  num get totalEfectivo => ingresos
      .where((i) => i.medioDePago?.toLowerCase() == 'efectivo')
      .fold(0, (sum, i) => sum + i.monto);

  num get totalTransferencia => ingresos
      .where((i) => i.medioDePago?.toLowerCase() == 'transferencia')
      .fold(0, (sum, i) => sum + i.monto);

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
