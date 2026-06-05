import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/builder/top_bar.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';

void main() {
  group('TopBar Widget Tests', () {
    final mockAlumnos = [
      Alumno(
        idAlumno: 'abc-123',
        nombre: 'Juan',
        apellido: 'Pérez',
        aplicaDescuento: false,
      ),
      Alumno(
        idAlumno: 'def-456',
        nombre: 'María',
        apellido: 'García',
        aplicaDescuento: true,
      ),
    ];

    Widget createWidgetUnderTest({
      VoidCallback? onBack,
      Alumno? alumnoSeleccionado,
      VoidCallback? onGuardar,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TopBar(
            onBack: onBack ?? () {},
            alumnos: mockAlumnos,
            alumnoSeleccionado: alumnoSeleccionado,
            onAlumnoChanged: (_) {},
            routineNameController: TextEditingController(),
            onGuardar: onGuardar,
          ),
        ),
      );
    }

    testWidgets('debe mostrar el nombre del gimnasio', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Le Groupe Gym'), findsOneWidget);
    });

    testWidgets('debe mostrar el botón de volver', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('debe llamar onBack al presionar la flecha', (tester) async {
      // Arrange
      bool backPressed = false;
      await tester.pumpWidget(
        createWidgetUnderTest(onBack: () => backPressed = true),
      );

      // Act
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();

      // Assert
      expect(backPressed, isTrue);
    });
    testWidgets('debe mostrar el selector de alumno', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(DropdownMenu<Alumno>), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe mostrar el campo de nombre de rutina', (tester) async {
      // Arrange + Act
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byKey(const Key('routine_name_field')), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets(
      'el botón guardar debe estar deshabilitado sin alumno seleccionado',
      (tester) async {
        // Arrange + Act
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(createWidgetUnderTest(onGuardar: null));

        // Assert
        final boton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(boton.onPressed, isNull);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );

    testWidgets(
      'el botón guardar debe estar habilitado con alumno seleccionado',
      (tester) async {
        // Arrange + Act
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(
          createWidgetUnderTest(
            alumnoSeleccionado: mockAlumnos.first,
            onGuardar: () {},
          ),
        );

        // Assert
        final boton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(boton.onPressed, isNotNull);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
  });
}
