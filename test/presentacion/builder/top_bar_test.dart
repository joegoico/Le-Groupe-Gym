import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/top_bar.dart';

void main() {
  group('TopBar Widget Tests', () {
    Widget createWidgetUnderTest({
      VoidCallback? onMenuPressed,
      String pageTitle = 'Rutinas',
      List<Widget>? actionsCenter,
      List<Widget>? actionsEnd,
      bool isBack = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TopBar(
            onMenuPressed: onMenuPressed ?? () {},
            pageTitle: pageTitle,
            actionsCenter: actionsCenter,
            actionsEnd: actionsEnd,
            isBack: isBack,
          ),
        ),
      );
    }

    testWidgets('debe mostrar el título de la página', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest(pageTitle: 'Rutinas'));

      // Assert
      expect(find.text('Rutinas'), findsOneWidget);
    });

    testWidgets('debe mostrar el botón de menú', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('debe llamar onMenuPressed al presionar el menú', (
      tester,
    ) async {
      // Arrange
      bool menuPressed = false;
      await tester.pumpWidget(
        createWidgetUnderTest(onMenuPressed: () => menuPressed = true),
      );

      // Act
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump();

      // Assert
      expect(menuPressed, isTrue);
    });
    testWidgets('debe mostrar los actionsCenter cuando se pasan', (
      tester,
    ) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        createWidgetUnderTest(
          actionsCenter: [
            ElevatedButton(onPressed: () {}, child: const Text('Centro')),
          ],
        ),
      );

      // Assert
      expect(find.text('Centro'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar los actionsEnd cuando se pasan', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        createWidgetUnderTest(
          actionsEnd: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Guardar Rutina'),
            ),
          ],
        ),
      );

      // Assert
      expect(find.text('Guardar Rutina'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
    testWidgets('debe mostrar flecha back cuando isBack es true', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest(isBack: true));

      // Assert
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsNothing);
    });

    testWidgets('debe mostrar hamburguesa cuando isBack es false', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest(isBack: false));

      // Assert
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });
  });
}
