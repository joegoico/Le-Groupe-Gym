import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/presentacion/forms/solicitud_rutina_form.dart';
import '../../mocks/mock_alumno_repository.dart';
import '../../mocks/mock_solicitud_rutina_repository.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';

void main() {
  group('AddSolicitudRutinaForm Tests', () {
    // Test cases will go here
    Widget createWidgetUnderTest({
      VoidCallback? onCancelar,
      ValueChanged<SolicitudRutina>? onGuardar,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AddSolicitudRutinaForm(
            onCancelar: onCancelar ?? () {},
            onGuardar: onGuardar ?? (_) {},
            alumnoRepository: MockAlumnoRepository(),
            solicitudRutinaRepository: MockSolicitudRutinaRepository(),
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
  });
}
