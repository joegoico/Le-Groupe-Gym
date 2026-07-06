import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/pages/routine_work_page.dart';
import 'package:le_groupe_gym/presentacion/builder/exercise_sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_workspace.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import '../../mocks/mock_exercise_repository.dart';
import '../../mocks/mock_routine_repository.dart';
import '../../mocks/mock_alumno_repository.dart';
import '../../mocks/mock_category_exercise_repository.dart';
import '../../mocks/mock_solicitud_rutina_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/data/repositories/solicitud_rutina_repository.dart';

class TestAlumnoRepository extends MockAlumnoRepository {
  @override
  Future<List<Alumno>> getAlumnos() async {
    // Le forzamos al test a devolver exactamente el alumno que necesitamos
    return [
      Alumno(
        idAlumno: 'abc-123',
        nombre: 'Lucas',
        apellido: 'Benítez',
        aplicaDescuento: true,
        // Si tu modelo Alumno requiere otros campos (como mail, fechaNacimiento, etc.),
        // agregalos acá con datos de relleno.
      ),
    ];
  }
}

class SpySolicitudRepository extends MockSolicitudRutinaRepository {
  bool deleteFueLlamado = false;
  int? idEliminado;

  @override
  Future<void> deleteSolicitud(int idSolicitud) async {
    // ¡Anotamos que alguien nos llamó!
    deleteFueLlamado = true;
    idEliminado = idSolicitud;

    // Y luego dejamos que el mock original haga lo suyo
    await super.deleteSolicitud(idSolicitud);
  }
}

void main() {
  group('MainPanelPage Widget Tests - Flujo Asíncrono AAA', () {
    // Agregamos parámetros para inyectar dependencias específicas por test
    Widget createWidgetUnderTest({
      SolicitudRutina? solicitudOrigen,
      SolicitudRutinaRepository? mockSolicitudRepo,
    }) {
      // Usamos GoRouter para que los context.pop() no tiren excepciones
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                MainPanelPage(solicitudOrigen: solicitudOrigen),
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          exerciseRepositoryProvider.overrideWithValue(
            MockExerciseRepository(),
          ),
          routineRepositoryProvider.overrideWithValue(MockRoutineRepository()),
          alumnoRepositoryProvider.overrideWithValue(TestAlumnoRepository()),
          categoryExerciseRepositoryProvider.overrideWithValue(
            MockCategoryExerciseRepository(),
          ),
          // Inyectamos el repo de solicitudes (si no nos pasan uno, usamos el mock por defecto)
          solicitudRutinaRepositoryProvider.overrideWithValue(
            mockSolicitudRepo ?? MockSolicitudRutinaRepository(),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        ),
      );
    }

    testWidgets('Debe mostrar inicialmente el indicador de carga circular', (
      WidgetTester tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ExcerciseSidebar), findsNothing);
      expect(find.byType(RoutineWorkspace), findsNothing);

      await tester.pumpAndSettle();
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets(
      'Debe remover el loader y desplegar el panel completo tras resolver el repositorio',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(ExcerciseSidebar), findsOneWidget);
        expect(find.byType(RoutineWorkspace), findsOneWidget);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
    testWidgets(
      'debe mostrar snackbar al intentar agregar ejercicio duplicado',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Act — agregamos el mismo ejercicio dos veces via el botón +
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pump();
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pump();

        // Assert
        expect(
          find.text('Ese ejercicio ya está en el bloque activo.'),
          findsOneWidget,
        );

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
    // =========================================================================
    // PRUEBAS TDD - FLUJO DE SOLICITUDES (FASE ROJA)
    // =========================================================================

    // =========================================================================
    // PRUEBAS TDD - FLUJO DE SOLICITUDES (FASE ROJA/VERDE)
    // =========================================================================

    testWidgets('debe pre-seleccionar al alumno si recibe una solicitudOrigen', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);

      final solicitud = SolicitudRutina(
        idSolicitud: 1,
        idAlumno:
            'abc-123', // CORREGIDO: Ahora coincide con el TestAlumnoRepository
        fechaSolicitud: DateTime.now(),
        alumnoNombre: 'Lucas',
        alumnoApellido: 'Benítez',
      );

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(solicitudOrigen: solicitud),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Lucas Benítez'),
        findsOneWidget,
        reason: 'El selector de alumnos debería mostrar al alumno precargado',
      );

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('debe borrar la solicitud tras guardar la rutina exitosamente', (
      tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);

      // CORREGIDO: Instanciamos el ESPÍA, no el mock normal
      final spyRepo = SpySolicitudRepository();

      final solicitud = SolicitudRutina(
        idSolicitud: 99,
        idAlumno:
            'abc-123', // CORREGIDO: Ahora coincide con el TestAlumnoRepository
        fechaSolicitud: DateTime.now(),
        alumnoNombre: 'Lucas',
        alumnoApellido: 'Benítez',
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          solicitudOrigen: solicitud,
          mockSolicitudRepo: spyRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Act 1: Agregamos un ejercicio para que la rutina sea válida
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      // Act 2: Guardamos la rutina
      await tester.tap(find.widgetWithText(ElevatedButton, 'Guardar Rutina'));
      await tester.pumpAndSettle();

      // Assert: CORREGIDO - Le preguntamos a las variables internas del ESPÍA
      expect(
        spyRepo.deleteFueLlamado,
        isTrue,
        reason: 'Se debió llamar a deleteSolicitud',
      );
      expect(spyRepo.idEliminado, 99);

      addTearDown(tester.view.resetPhysicalSize);
    });
  }); // ← cierre del group
}
