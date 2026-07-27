import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/builder/sidebar.dart';

void main() {
  group('Sidebar Widget Tests', () {
    Widget createWidgetUnderTest({
      String currentRoute = '/rutinas',
      bool isCollapsed = false,
      VoidCallback? onCerrarSesion,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              Sidebar(
                currentRoute: currentRoute,
                isCollapsed: isCollapsed,
                onCerrarSesion: onCerrarSesion ?? () {},
                onNavigate: (_) {},
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    testWidgets('debe mostrar el nombre del gimnasio cuando está expandido', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Le Groupe Gym'), findsOneWidget);
    });

    testWidgets('debe ocultar el nombre cuando está colapsado', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest(isCollapsed: true));

      // Assert
      expect(find.text('Le Groupe Gym'), findsNothing);
    });

    testWidgets('debe mostrar todos los items de navegación', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Alumnos'), findsOneWidget);
      expect(find.text('Deudores'), findsOneWidget);
      expect(find.text('Gastos'), findsOneWidget);
      expect(find.text('Precios'), findsOneWidget);
      expect(find.text('Rutinas'), findsOneWidget);
    });

    testWidgets('debe ocultar texto de items cuando está colapsado', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest(isCollapsed: true));

      // Assert
      expect(find.text('Rutinas'), findsNothing);
      expect(find.text('Alumnos'), findsNothing);
    });

    testWidgets('debe mostrar el botón cerrar sesión', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('debe llamar onCerrarSesion al presionar cerrar sesión', (
      tester,
    ) async {
      // Arrange
      bool pressed = false;
      await tester.pumpWidget(
        createWidgetUnderTest(onCerrarSesion: () => pressed = true),
      );

      // Act
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pump();

      // Assert
      expect(pressed, isTrue);
    });

    testWidgets('debe llamar onNavigate al presionar Rutinas', (tester) async {
      // Arrange
      String? navigatedTo;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Sidebar(
                  currentRoute: '/',
                  isCollapsed: false,
                  onCerrarSesion: () {},
                  onNavigate: (route) => navigatedTo = route,
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Rutinas'));
      await tester.pump();

      // Assert
      expect(navigatedTo, '/rutinas');
    });
  });
}
