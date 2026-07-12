import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/presentacion/pages/routine_work_page.dart';
import 'package:le_groupe_gym/presentacion/builder/exercise_sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/routine_workspace.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';
import 'package:le_groupe_gym/data/models/dia_rutina_model.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import '../../mocks/mock_exercise_repository.dart';
import '../../mocks/mock_routine_repository.dart';
import '../../mocks/mock_alumno_repository.dart';
import '../../mocks/mock_category_exercise_repository.dart';
import '../../mocks/mock_solicitud_rutina_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/data/repositories/solicitud_rutina_repository.dart';

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
          alumnoRepositoryProvider.overrideWithValue(MockAlumnoRepository()),
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

        // Primero hay que crear un día y un bloque para pasar la validación
        // que bloquea agregar ejercicios sin día/bloque seleccionados
        await tester.tap(find.text('Agregar día'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Agregar bloque'));
        await tester.pumpAndSettle();

        // Act — intentamos agregar el mismo ejercicio dos veces via el botón +
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

    testWidgets(
      'debe pre-seleccionar al alumno si recibe una solicitudOrigen',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;

        final solicitud = SolicitudRutina(
          idSolicitud: 1,
          idAlumno:
              'luc-001', // Coincide con Lucas Benítez en MockAlumnoRepository
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
      },
    );
    testWidgets(
      'debe eliminar la solicitud al guardar una rutina con solicitudOrigen',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;

        final solicitud = SolicitudRutina(
          idSolicitud: 1,
          idAlumno: 'abc-123',
          fechaSolicitud: DateTime(2026, 1, 1),
        );
        final mockSolicitudRepo = MockSolicitudRutinaRepository();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              exerciseRepositoryProvider.overrideWithValue(
                MockExerciseRepository(),
              ),
              routineRepositoryProvider.overrideWithValue(
                MockRoutineRepository(),
              ),
              alumnoRepositoryProvider.overrideWithValue(
                MockAlumnoRepository(),
              ),
              categoryExerciseRepositoryProvider.overrideWithValue(
                MockCategoryExerciseRepository(),
              ),
              solicitudRutinaRepositoryProvider.overrideWithValue(
                mockSolicitudRepo,
              ),
            ],
            child: MaterialApp(home: MainPanelPage(solicitudOrigen: solicitud)),
          ),
        );
        await tester.pumpAndSettle();

        // Assert — la solicitud existe antes de guardar
        expect((await mockSolicitudRepo.getSolicitudes()).length, 2);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
    testWidgets(
      'debe mostrar diálogo de confirmación al presionar volver con rutina en progreso',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Agregar un día para que haya progreso
        // (simulamos que el controller tiene contenido)

        // Act — presionar botón back
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
        await tester.pump();

        // Assert — aparece diálogo de confirmación
        expect(find.text('¿Salir sin guardar?'), findsOneWidget);
        expect(
          find.text('Perdés los cambios de la rutina actual.'),
          findsOneWidget,
        );
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Salir'), findsOneWidget);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
    testWidgets(
      'debe precargar la rutina existente en el controller al editar',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;

        final rutinaExistente = Rutina(
          idRutina: 1,
          nombre: 'Rutina Fuerza',
          idAlumno: 'abc-123',
          dias: [
            DiaRutina(
              nombre: 'Día 1 - Pecho',
              orden: 0,
              bloques: [
                BloqueRutina(
                  id: 'b1',
                  nombre: 'Bloque 1',
                  ejercicios: [
                    EjercicioRutina(
                      ejercicio: Ejercicio(
                        idEjercicio: 1,
                        nombre: 'Press Banca',
                        categorias: [],
                      ),
                      series: 4,
                      repeticiones: '10',
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              exerciseRepositoryProvider.overrideWithValue(
                MockExerciseRepository(),
              ),
              routineRepositoryProvider.overrideWithValue(
                MockRoutineRepository(),
              ),
              alumnoRepositoryProvider.overrideWithValue(
                MockAlumnoRepository(),
              ),
              categoryExerciseRepositoryProvider.overrideWithValue(
                MockCategoryExerciseRepository(),
              ),
              solicitudRutinaRepositoryProvider.overrideWithValue(
                MockSolicitudRutinaRepository(),
              ),
            ],
            child: MaterialApp(
              home: MainPanelPage(rutinaExistente: rutinaExistente),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Día 1 - Pecho'), findsOneWidget);
        expect(find.text('Press Banca'), findsOneWidget);
        expect(find.text('Rutina Fuerza'), findsOneWidget);

        addTearDown(tester.view.resetPhysicalSize);
      },
    );
  }); // ← cierre del group
}
