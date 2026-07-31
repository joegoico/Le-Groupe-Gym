// test/data_tests/models/resumen_mensual_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/resumen_mensual_model.dart';

void main() {
  group('ResumenMensual Model Tests', () {
    // Ahora los totales vienen directamente desde la RPC (no se calculan de la lista)
    final resumen = ResumenMensual(
      mes: 6,
      anio: 2026,
      totalEfectivo: 25000,
      totalTransferencia: 18000,
      total: 43000,
    );

    test('debe tener el total correcto', () {
      expect(resumen.total, 43000);
    });

    test('debe tener el total de efectivo correcto', () {
      expect(resumen.totalEfectivo, 25000);
    });

    test('debe tener el total de transferencia correcto', () {
      expect(resumen.totalTransferencia, 18000);
    });

    test('debe tener getter de título del mes', () {
      expect(resumen.titulo, 'Junio 2026');
    });

    group('fromRpc', () {
      test('parsea correctamente todos los campos numéricos', () {
        final map = {
          'anio': 2026,
          'mes': 7,
          'total_efectivo': 15000.0,
          'total_transferencia': 18000.0,
          'total': 33000.0,
        };

        final r = ResumenMensual.fromRpc(map);

        expect(r.anio, 2026);
        expect(r.mes, 7);
        expect(r.totalEfectivo, 15000);
        expect(r.totalTransferencia, 18000);
        expect(r.total, 33000);
      });

      test('maneja enteros de Postgres correctamente', () {
        final map = {
          'anio': 2026,
          'mes': 3,
          'total_efectivo': 5000,
          'total_transferencia': 10000,
          'total': 15000,
        };

        final r = ResumenMensual.fromRpc(map);
        expect(r.total, 15000);
      });

      test('maneja valores en cero', () {
        final map = {
          'anio': 2026,
          'mes': 1,
          'total_efectivo': 0.0,
          'total_transferencia': 0.0,
          'total': 0.0,
        };
        final r = ResumenMensual.fromRpc(map);
        expect(r.total, 0);
        expect(r.totalEfectivo, 0);
      });
    });
  });
}
