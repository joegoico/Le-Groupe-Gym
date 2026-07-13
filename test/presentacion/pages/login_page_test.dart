import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/auth/login_page.dart';

void main() {
  group('LoginPage Widget Tests', () {
    Widget createWidgetUnderTest({VoidCallback? onLogin}) {
      return MaterialApp(home: LoginPage(onLogin: onLogin ?? () {}));
    }

    testWidgets('debe mostrar el logo y nombre del gimnasio', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Le Groupe Gym'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('debe mostrar campo de email', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byKey(const Key('email_field')), findsOneWidget);
    });

    testWidgets('debe mostrar campo de password', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byKey(const Key('password_field')), findsOneWidget);
    });

    testWidgets('debe mostrar botón de ingresar', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Ingresar'), findsOneWidget);
    });

    testWidgets(
      'el botón ingresar debe estar deshabilitado si los campos están vacíos',
      (tester) async {
        // Arrange + Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Assert
        final boton = tester.widget<ElevatedButton>(
          find.ancestor(
            of: find.text('Ingresar'),
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(boton.onPressed, isNull);
      },
    );

    testWidgets(
      'el botón ingresar debe habilitarse al completar ambos campos',
      (tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'profesor@gym.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          '123456',
        );
        await tester.pump();

        // Assert
        final boton = tester.widget<ElevatedButton>(
          find.ancestor(
            of: find.text('Ingresar'),
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(boton.onPressed, isNotNull);
      },
    );

    testWidgets('debe mostrar error si las credenciales son incorrectas', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'mal@email.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrongpass',
      );
      await tester.pump();

      // Act
      await tester.tap(find.text('Ingresar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Credenciales incorrectas'), findsOneWidget);
    });
  });
}
