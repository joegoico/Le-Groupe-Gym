import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_widgets/solicitudes_panel.dart';

void main() {
  group('SolicitudesPanel Widget Tests', () {
    final mockSolicitudes = [
      SolicitudRutina(
        idSolicitud: 1,
        idAlumno: 'abc-123',
        fechaSolicitud: DateTime(2026, 1, 1),
        notas: 'Quiero cambiar mi rutina de piernas',
      ),
      SolicitudRutina(
        idSolicitud: 2,
        idAlumno: 'def-456',
        fechaSolicitud: DateTime(2026, 1, 2),
      ),
    ];

    Widget createWidgetUnderTest({
      List<SolicitudRutina>? solicitudes,
      VoidCallback? onRegistrarSolicitud,
      Function(SolicitudRutina)? onResolverSolicitud,
      Function(SolicitudRutina)? onEliminarSolicitud,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SolicitudesPanel(
            solicitudes: solicitudes ?? mockSolicitudes,
            onRegistrarSolicitud: onRegistrarSolicitud ?? () {},
            onResolverSolicitud: onResolverSolicitud ?? (_) {},
            onEliminarSolicitud: onEliminarSolicitud ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('debe mostrar el contador de solicitudes pendientes', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('2 Rutinas Pendientes'), findsOneWidget);
    });

    testWidgets('debe mostrar el botón registrar solicitud', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Registrar solicitud'), findsOneWidget);
    });

    testWidgets('debe llamar onRegistrarSolicitud al presionar el botón', (
      tester,
    ) async {
      // Arrange
      bool pressed = false;
      await tester.pumpWidget(
        createWidgetUnderTest(onRegistrarSolicitud: () => pressed = true),
      );

      // Act
      await tester.tap(find.text('Registrar solicitud'));
      await tester.pump();

      // Assert
      expect(pressed, isTrue);
    });

    testWidgets('debe mostrar las solicitudes al expandir el panel', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      // Usamos el mismo mock que venimos usando que tiene el alumnoNombre configurado
      await tester.pumpWidget(
        createWidgetUnderTest(
          solicitudes: [
            SolicitudRutina(
              idSolicitud: 1,
              idAlumno: 'abc-123',
              fechaSolicitud: DateTime(2026, 1, 1),
              notas: 'Quiero cambiar mi rutina de piernas',
              alumnoNombre: 'Lucas', // <-- Este dato ya lo soporta el modelo
              alumnoApellido:
                  'Benítez', // <-- Este dato ya lo soporta el modelo
            ),
          ],
        ),
      );

      // Assert — por defecto colapsado
      expect(find.text('Quiero cambiar mi rutina de piernas'), findsNothing);

      // Act — expandir
      await tester.tap(
        find.text('1 Rutinas Pendientes'),
      ); // Ajustado a 1 porque mandamos 1
      await tester.pumpAndSettle();

      // Assert — ahora verificamos todo el contenido
      expect(find.text('Quiero cambiar mi rutina de piernas'), findsOneWidget);
      expect(
        find.text('Lucas Benítez'),
        findsOneWidget,
      ); // <-- ESTE ES EL NUEVO REQUISITO QUE VA A FALLAR
      expect(
        find.text('abc-123'),
        findsNothing,
      ); // <-- Ya NO queremos ver el ID pelado

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar botón resolver por cada solicitud al expandir', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      // Act — expandir
      await tester.tap(find.text('2 Rutinas Pendientes'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Resolver'), findsNWidgets(2));

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe llamar onResolverSolicitud al presionar Resolver', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      SolicitudRutina? resuelta;
      await tester.pumpWidget(
        createWidgetUnderTest(onResolverSolicitud: (s) => resuelta = s),
      );

      // Act — expandir el panel para que aparezcan los botones
      await tester.tap(find.text('2 Rutinas Pendientes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resolver').first);
      await tester.pump();

      // Assert
      expect(resuelta, isNotNull);
      expect(resuelta!.idSolicitud, 1);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar mensaje si no hay solicitudes', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest(solicitudes: []));

      // Act — expandir el panel para ver el contenido
      await tester.tap(find.text('0 Rutinas Pendientes'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No hay solicitudes pendientes'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
    testWidgets('debe mostrar icono de basura antes del boton resolver', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      // Act — expandir
      await tester.tap(find.text('2 Rutinas Pendientes'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.delete_outline_outlined), findsNWidgets(2));

      addTearDown(tester.view.resetPhysicalSize);
    });
    testWidgets(
      'debe llamar onEliminarSolicitud al presionar el botón eliminar',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        SolicitudRutina? eliminada;

        await tester.pumpWidget(
          createWidgetUnderTest(onEliminarSolicitud: (s) => eliminada = s),
        );

        // Expandir el panel
        await tester.tap(find.text('2 Rutinas Pendientes'));
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byIcon(Icons.delete_outline_outlined).first);
        await tester.pump();

        // Assert
        expect(eliminada, isNotNull);
        expect(eliminada!.idSolicitud, 1);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
  });
}
