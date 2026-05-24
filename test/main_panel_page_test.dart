import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/pages/main_panel_page.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/exercise_sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/routine_workspace.dart';

void main() {
  group('MainPanelPage Widget Tests - Flujo Asíncrono AAA', () {
    
    Widget createWidgetUnderTest() {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainPanelPage(),
      );
    }

    testWidgets('Debe mostrar inicialmente el indicador de carga circular', (WidgetTester tester) async {
      // Arrange: Seteamos pantalla de escritorio
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      // Act: Montamos la pantalla (Inicia el Future de 500ms del Mock)
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert: Al inicio exacto, debe figurar el loader y nada de la estructura
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ExcerciseSidebar), findsNothing);
      expect(find.byType(RoutineWorkspace), findsNothing);

      await tester.pumpAndSettle();

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('Debe remover el loader y desplegar el panel completo tras resolver el repositorio', (WidgetTester tester) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      // Act: Adelantamos el reloj virtual 500ms para que se cumpla el Future.delayed del repo
      await tester.pump(const Duration(milliseconds: 500));

      // Assert: El loader desaparece y los dos grandes bloques visuales se montan en el Row
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ExcerciseSidebar), findsOneWidget);
      expect(find.byType(RoutineWorkspace), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
