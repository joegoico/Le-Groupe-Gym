import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/data/models/deudor_model.dart';
import 'package:le_groupe_gym/presentacion/pages/detalle_widgets/estado_cuenta_card.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets(
    'EstadoCuentaCard muestra Cuota Vencida cuando el pago está vencido',
    (WidgetTester tester) async {
      // Crear un pago que venció hace 5 días
      final hoy = DateTime.now();
      final fechaPago = hoy.subtract(const Duration(days: 35));

      final pagoVencido = Pago(
        idPago: '1',
        fechaDePago: fechaPago,
        monto: 1000,
        medioDePago: 'Efectivo',
        comentarios: '',
        idAlumno: '1',
        cantidadDias: 30,
        aplicaDescuento: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EstadoCuentaCard(
              ultimoPago: pagoVencido,
              deudor: Deudor(
                idDeudor: '1',
                nombre: 'Juan',
                apellido: 'Perez',
                diasAdeudados: 5,
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Cuota Vencida'), findsOneWidget);

      final formatoFecha = DateFormat('dd/MM/yyyy');
      final proximoVencimiento = formatoFecha.format(
        fechaPago.add(const Duration(days: 30)),
      );
      expect(find.text(proximoVencimiento), findsOneWidget);

      expect(
        find.text('Último pago: ${formatoFecha.format(fechaPago)}'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'EstadoCuentaCard muestra Cuota al Día cuando el pago no está vencido',
    (WidgetTester tester) async {
      // Crear un pago que vence en 5 días
      final hoy = DateTime.now();
      final fechaPago = hoy.subtract(const Duration(days: 25));

      final pagoAlDia = Pago(
        idPago: '1',
        fechaDePago: fechaPago,
        monto: 1000,
        medioDePago: 'Efectivo',
        comentarios: '',
        idAlumno: '1',
        cantidadDias: 30,
        aplicaDescuento: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EstadoCuentaCard(ultimoPago: pagoAlDia, deudor: null),
          ),
        ),
      );

      expect(find.text('Cuota al Día'), findsOneWidget);

      final formatoFecha = DateFormat('dd/MM/yyyy');
      final proximoVencimiento = formatoFecha.format(
        fechaPago.add(const Duration(days: 30)),
      );
      expect(find.text(proximoVencimiento), findsOneWidget);

      expect(
        find.text('Último pago: ${formatoFecha.format(fechaPago)}'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'EstadoCuentaCard muestra Sin pagos registrados cuando ultimoPago es nulo y oculta días adeudados',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EstadoCuentaCard(
              ultimoPago: null,
              deudor: Deudor(
                idDeudor: '1',
                nombre: 'Juan',
                apellido: 'Perez',
                diasAdeudados: 5,
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sin pagos registrados'), findsOneWidget);
    },
  );
}
