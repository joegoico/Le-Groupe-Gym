import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/presentacion/forms/alumno_form.dart';
import '../../mocks/mock_alumno_repository.dart';
import 'package:le_groupe_gym/data/repositories/alumno_repository.dart';

class _PendingAlumnoRepository extends MockAlumnoRepository {
  final Completer<List<Alumno>> _alumnos = Completer<List<Alumno>>();

  @override
  Future<List<Alumno>> getAlumnos({int limit = 50, int offset = 0}) =>
      _alumnos.future;

  void completeWith(List<Alumno> alumnos) => _alumnos.complete(alumnos);
}

void main() {
  group('AlumnoForm Widget Tests', () {
    late MockAlumnoRepository mockRepo;

    setUp(() => mockRepo = MockAlumnoRepository());

    Widget createWidgetUnderTest({
      Alumno? alumno,
      ValueChanged<Alumno>? onGuardar,
      VoidCallback? onCancelar,
      AlumnoRepository? alumnoRepository,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AlumnoForm(
              alumno: alumno,
              alumnoRepository: alumnoRepository ?? mockRepo,
              onGuardar: onGuardar ?? (_) {},
              onCancelar: onCancelar ?? () {},
            ),
          ),
        ),
      );
    }

    // ── Presencia de campos ───────────────────────────────────────────────────

    testWidgets('debe mostrar los campos nombre, apellido y mail', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byKey(const Key('alumno_nombre_field')), findsOneWidget);
      expect(find.byKey(const Key('alumno_apellido_field')), findsOneWidget);
      expect(find.byKey(const Key('alumno_mail_field')), findsOneWidget);
    });

    testWidgets('debe mostrar botones Cancelar y Guardar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Crear Alumno'), findsOneWidget);
    });

    testWidgets('debe mostrar título "Nuevo Alumno" en modo creación', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nuevo Alumno'), findsOneWidget);
    });

    testWidgets('debe mostrar título "Editar Alumno" en modo edición', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          alumno: Alumno(
            idAlumno: 'abc-123',
            nombre: 'Juan',
            apellido: 'Pérez',
          ),
        ),
      );

      expect(find.text('Editar Alumno'), findsOneWidget);
    });

    // ── Validaciones ──────────────────────────────────────────────────────────

    testWidgets('debe mostrar error si nombre está vacío al guardar', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // No ingresamos nada y tocamos Guardar
      await tester.tap(find.byKey(const Key('alumno_guardar_button')));
      await tester.pump();

      expect(find.text('El nombre es requerido'), findsOneWidget);
    });

    testWidgets('debe mostrar error si apellido está vacío al guardar', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.byKey(const Key('alumno_nombre_field')),
        'Juan',
      );
      await tester.tap(find.byKey(const Key('alumno_guardar_button')));
      await tester.pump();

      expect(find.text('El apellido es requerido'), findsOneWidget);
    });

    testWidgets('debe mostrar error si el mail tiene formato inválido', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.byKey(const Key('alumno_nombre_field')),
        'Juan',
      );
      await tester.enterText(
        find.byKey(const Key('alumno_apellido_field')),
        'Pérez',
      );
      await tester.enterText(
        find.byKey(const Key('alumno_mail_field')),
        'no-es-un-mail',
      );
      await tester.tap(find.byKey(const Key('alumno_guardar_button')));
      await tester.pump();

      expect(find.text('Formato de email inválido'), findsOneWidget);
    });

    testWidgets('debe aceptar mail vacío (campo opcional)', (tester) async {
      Alumno? guardado;
      await tester.pumpWidget(
        createWidgetUnderTest(onGuardar: (a) => guardado = a),
      );

      await tester.enterText(
        find.byKey(const Key('alumno_nombre_field')),
        'Pablo',
      );
      await tester.enterText(
        find.byKey(const Key('alumno_apellido_field')),
        'Farias',
      );
      // mail vacío — no ingresamos nada
      await tester.tap(find.byKey(const Key('alumno_guardar_button')));
      await tester.pumpAndSettle();

      expect(guardado, isNotNull);
      expect(guardado!.mail, isNull);
    });

    testWidgets(
      'muestra inline el error si ya existe un alumno, sin distinguir mayúsculas',
      (tester) async {
        var guardados = 0;
        await tester.pumpWidget(
          createWidgetUnderTest(onGuardar: (_) => guardados++),
        );

        await tester.enterText(
          find.byKey(const Key('alumno_nombre_field')),
          'juan',
        );
        await tester.enterText(
          find.byKey(const Key('alumno_apellido_field')),
          'PÉREZ',
        );
        await tester.tap(find.byKey(const Key('alumno_guardar_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('error-alumno-duplicado')), findsOneWidget);
        expect(
          find.text('Ya existe un alumno con ese nombre y apellido.'),
          findsOneWidget,
        );
        expect(guardados, isZero);
      },
    );

    testWidgets(
      'muestra Guardando y bloquea el botón mientras verifica duplicados',
      (tester) async {
        final repository = _PendingAlumnoRepository();
        await tester.pumpWidget(
          createWidgetUnderTest(alumnoRepository: repository),
        );

        await tester.enterText(
          find.byKey(const Key('alumno_nombre_field')),
          'Sofía',
        );
        await tester.enterText(
          find.byKey(const Key('alumno_apellido_field')),
          'Navarro',
        );
        await tester.tap(find.byKey(const Key('alumno_guardar_button')));
        await tester.pump();

        expect(find.text('Guardando...'), findsOneWidget);
        final button = tester.widget<ElevatedButton>(
          find.byKey(const Key('alumno_guardar_button')),
        );
        expect(button.onPressed, isNull);

        repository.completeWith([]);
        await tester.pumpAndSettle();
      },
    );

    // ── Callbacks ─────────────────────────────────────────────────────────────

    testWidgets('debe llamar onCancelar al presionar Cancelar', (tester) async {
      bool cancelado = false;
      await tester.pumpWidget(
        createWidgetUnderTest(onCancelar: () => cancelado = true),
      );

      await tester.tap(find.text('Cancelar'));
      await tester.pump();

      expect(cancelado, isTrue);
    });

    testWidgets('debe llamar onGuardar con datos correctos al crear alumno', (
      tester,
    ) async {
      Alumno? guardado;
      await tester.pumpWidget(
        createWidgetUnderTest(onGuardar: (a) => guardado = a),
      );

      await tester.enterText(
        find.byKey(const Key('alumno_nombre_field')),
        'Florencia',
      );
      await tester.enterText(
        find.byKey(const Key('alumno_apellido_field')),
        'Luna',
      );
      await tester.enterText(
        find.byKey(const Key('alumno_mail_field')),
        'florencia@mail.com',
      );
      await tester.tap(find.byKey(const Key('alumno_guardar_button')));
      await tester.pumpAndSettle();

      expect(guardado, isNotNull);
      expect(guardado!.nombre, 'Florencia');
      expect(guardado!.apellido, 'Luna');
      expect(guardado!.mail, 'florencia@mail.com');
    });

    // ── Modo edición ──────────────────────────────────────────────────────────

    testWidgets('debe precargar los datos del alumno en modo edición', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          alumno: Alumno(
            idAlumno: 'abc-123',
            nombre: 'Lucas',
            apellido: 'Benítez',
            mail: 'lucas@mail.com',
          ),
        ),
      );

      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('alumno_nombre_field')))
            .controller
            ?.text,
        'Lucas',
      );
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const Key('alumno_apellido_field')),
            )
            .controller
            ?.text,
        'Benítez',
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('alumno_mail_field')))
            .controller
            ?.text,
        'lucas@mail.com',
      );
    });

    testWidgets('debe llamar onGuardar con id del alumno existente al editar', (
      tester,
    ) async {
      Alumno? guardado;
      await tester.pumpWidget(
        createWidgetUnderTest(
          alumno: Alumno(
            idAlumno: 'abc-123',
            nombre: 'Lucas',
            apellido: 'Benítez',
            mail: 'lucas@mail.com',
          ),
          onGuardar: (a) => guardado = a,
        ),
      );

      // Modificamos el nombre
      await tester.enterText(
        find.byKey(const Key('alumno_nombre_field')),
        'Luca',
      );
      await tester.tap(find.byKey(const Key('alumno_guardar_button')));
      await tester.pump();

      expect(guardado!.idAlumno, 'abc-123');
      expect(guardado!.nombre, 'Luca');
    });
  });
}
