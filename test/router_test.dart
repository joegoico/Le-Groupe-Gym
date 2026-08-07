import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Imports de tus componentes reales de producción
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_dashbord_page.dart';
import 'package:le_groupe_gym/presentacion/pages/routine_work_page.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';

// Import de tus mocks
import 'mocks/mock_solicitud_rutina_repository.dart';
import 'mocks/mock_routine_repository.dart';
import 'mocks/mock_alumno_repository.dart';
import 'mocks/mock_exercise_repository.dart';
import 'mocks/mock_category_exercise_repository.dart';

void main() {
  group('Pruebas de Integración de Navegación Real', () {
    late GoRouter router;
    late MockSolicitudRutinaRepository mockRepository;

    setUp(() {
      // 1. Inicializás el mock del repositorio para que no le pegue a Supabase/API real
      mockRepository = MockSolicitudRutinaRepository();

      // El MockSolicitudRutinaRepository ya devuelve datos controlados directamente.

      // 2. Armás el router usando tus pantallas de verdad
      router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const RutinasDashboardPage(),
          ),
          GoRoute(
            path: '/crear-rutina',
            builder: (context, state) => const MainPanelPage(),
          ),
        ],
      );
    });

    testWidgets('Debe navegar desde el Dashboard de Rutinas al Creador de Rutinas', (
      WidgetTester tester,
    ) async {
      // Montamos la aplicación con ProviderScope (requerido por ConsumerStatefulWidget)
      // y con los repositorios mockeados para no conectar a Supabase.
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            solicitudRutinaRepositoryProvider.overrideWithValue(mockRepository),
            routineRepositoryProvider.overrideWithValue(
              MockRoutineRepository(),
            ),
            alumnoRepositoryProvider.overrideWithValue(MockAlumnoRepository()),
            exerciseRepositoryProvider.overrideWithValue(
              MockExerciseRepository(),
            ),
            categoryExerciseRepositoryProvider.overrideWithValue(
              MockCategoryExerciseRepository(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      addTearDown(tester.view.resetPhysicalSize);

      // Esperamos a que se procesen las peticiones asincrónicas iniciales (como los mocks)
      await tester.pumpAndSettle();

      // 1. Verificamos que estamos parados en tu Dashboard real
      expect(find.byType(RutinasDashboardPage), findsOneWidget);

      // 2. Buscamos el botón "Crear Rutina" en la TopBar (el "+" es un Icon separado)
      final botonCrear = find.text('Crear Rutina');
      expect(botonCrear, findsOneWidget);

      // 3. Simulamos la interacción del usuario
      await tester.tap(botonCrear);

      // Esperamos a que termine la animación de transición de la página
      await tester.pumpAndSettle();

      // 4. Verificaciones de éxito
      // Comprobamos que la ruta en GoRouter cambió
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        '/crear-rutina',
      );

      // Comprobamos que tu pantalla de creación de rutinas ya se está mostrando en los tests
      expect(find.byType(MainPanelPage), findsOneWidget);
      expect(find.byType(RutinasDashboardPage), findsNothing);
    });
  });
}
