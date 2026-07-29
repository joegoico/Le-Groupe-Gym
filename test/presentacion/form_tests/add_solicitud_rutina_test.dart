import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/deudor_model.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/presentacion/forms/solicitud_rutina_form.dart';
import '../../mocks/mock_alumno_repository.dart';
import '../../mocks/mock_solicitud_rutina_repository.dart';
import '../../mocks/mock_pago_repository.dart';
import '../../mocks/mock_deudor_repository.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';

void main() {
  group('AddSolicitudRutinaForm Tests', () {
    late MockAlumnoRepository mockAlumnoRepo;
    late MockSolicitudRutinaRepository mockSolicitudRepo;
    late MockPagoRepository mockPagoRepo;
    late MockDeudorRepository mockDeudorRepo;

    setUp(() {
      mockAlumnoRepo = MockAlumnoRepository();
      mockSolicitudRepo = MockSolicitudRutinaRepository();
      mockPagoRepo = MockPagoRepository();
      mockDeudorRepo = MockDeudorRepository();
      mockDeudorRepo.clearData();
    });

    Widget createWidgetUnderTest({
      VoidCallback? onCancelar,
      ValueChanged<SolicitudRutina>? onGuardar,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AddSolicitudRutinaForm(
            onCancelar: onCancelar ?? () {},
            onGuardar: onGuardar ?? (_) {},
            alumnoRepository: mockAlumnoRepo,
            solicitudRutinaRepository: mockSolicitudRepo,
            pagoRepository: mockPagoRepo,
            deudorRepository: mockDeudorRepo,
          ),
        ),
      );
    }

    testWidgets('debe mostrar el campo de selector del alumno', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificar que el campo de nombre del alumno esté presente
      expect(find.byType(AlumnoSelector), findsOneWidget);
    });

    testWidgets('no debe permitir guardar si no selecciona alumno', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final guardarButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('guardar_solicitud_button')),
      );

      expect(guardarButton.onPressed, isNull);
    });

    testWidgets('debe mostrar el campo de nombre de rutina', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificar que el campo de nombre de rutina esté presente
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('no debe permitir dejar en blanco el campo de nombre rutina', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Ingresar un nombre de rutina vacío
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      final guardarButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('guardar_solicitud_button')),
      );

      expect(guardarButton.onPressed, isNull);
    });

    testWidgets(
      'presionar Enter sin alumno seleccionado no debe enviar el formulario',
      (tester) async {
        // Arrange
        SolicitudRutina? guardado;
        await tester.pumpWidget(
          createWidgetUnderTest(onGuardar: (d) => guardado = d),
        );

        // Act — completamos el nombre pero NO seleccionamos alumno
        await tester.enterText(
          find.byKey(const Key('solicitud_rutina_name_field')),
          'Rutina 1',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Assert — sin alumno el formulario no debe enviarse
        expect(guardado, isNull);
        final guardarButton = tester.widget<ElevatedButton>(
          find.byKey(const Key('guardar_solicitud_button')),
        );
        expect(guardarButton.onPressed, isNull);
      },
    );

    testWidgets('debe mostrar advertencia si el alumno es deudor y permite cancelar', (tester) async {
      mockDeudorRepo.insertarDeudor(Deudor(idDeudor: 'abc-123', nombre: 'Juan', apellido: 'Pérez', diasAdeudados: 10, createdAt: DateTime.now()));
      mockPagoRepo.insertarPago(Pago(idPago: '1', idAlumno: 'abc-123', monto: 100, fechaDePago: DateTime.now(), medioDePago: 'efectivo', cantidadDias: 30));
      
      SolicitudRutina? guardado;
      await tester.pumpWidget(
        createWidgetUnderTest(onGuardar: (d) => guardado = d),
      );

      final alumnoField = find
          .descendant(
            of: find.byType(AddSolicitudRutinaForm),
            matching: find.byType(TextField),
          )
          .first;

      await tester.enterText(alumnoField, 'Juan');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Juan Pérez').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('solicitud_rutina_name_field')),
        'Rutina 1',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('guardar_solicitud_button')));
      await tester.pumpAndSettle();

      expect(find.text('Advertencia'), findsOneWidget);
      expect(find.textContaining('El alumno se encuentra en situación de deudor (hace 10 días).'), findsOneWidget);
      expect(find.textContaining('¿Desea continuar de todas formas?'), findsOneWidget);

      await tester.tap(find.text('Cancelar').last);
      await tester.pumpAndSettle();

      expect(guardado, isNull);
    });

    testWidgets('debe mostrar advertencia si no tiene pagos y permite continuar', (tester) async {
      SolicitudRutina? guardado;
      await tester.pumpWidget(
        createWidgetUnderTest(onGuardar: (d) => guardado = d),
      );

      final alumnoField = find
          .descendant(
            of: find.byType(AddSolicitudRutinaForm),
            matching: find.byType(TextField),
          )
          .first;

      await tester.enterText(alumnoField, 'Juan');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Juan Pérez').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('solicitud_rutina_name_field')),
        'Rutina 1',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('guardar_solicitud_button')));
      await tester.pumpAndSettle();

      expect(find.text('Advertencia'), findsOneWidget);
      expect(find.textContaining('El alumno no registra pagos.'), findsOneWidget);
      expect(find.textContaining('¿Desea continuar de todas formas?'), findsOneWidget);

      await tester.tap(find.text('Continuar').last);
      await tester.pumpAndSettle();

      expect(guardado, isNotNull);
    });
  });
}
