import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/presentacion/dashboard/widgets/solicitudes_panel.dart';

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
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SolicitudesPanel(
            solicitudes: solicitudes ?? mockSolicitudes,
            onRegistrarSolicitud: onRegistrarSolicitud ?? () {},
            onResolverSolicitud: onResolverSolicitud ?? (_) {},
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
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert — por defecto colapsado, no se ven las solicitudes
      expect(find.text('Quiero cambiar mi rutina de piernas'), findsNothing);

      // Act — expandir
      await tester.tap(find.text('2 Rutinas Pendientes'));
      await tester.pumpAndSettle();

      // Assert — ahora se ven
      expect(find.text('Quiero cambiar mi rutina de piernas'), findsOneWidget);

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
      SolicitudRutina? resuelta;
      await tester.pumpWidget(
        createWidgetUnderTest(onResolverSolicitud: (s) => resuelta = s),
      );

      // Act
      await tester.tap(find.text('Resolver').first);
      await tester.pump();

      // Assert
      expect(resuelta, isNotNull);
      expect(resuelta!.idSolicitud, 1);
    });

    testWidgets('debe mostrar mensaje si no hay solicitudes', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest(solicitudes: []));

      // Assert
      expect(find.text('No hay solicitudes pendientes'), findsOneWidget);
    });
  });
}
