import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:le_groupe_gym/main.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'mocks/mock_exercise_repository.dart';
import 'mocks/mock_routine_repository.dart';
import 'mocks/mock_alumno_repository.dart';
import 'mocks/mock_category_exercise_repository.dart';
import 'mocks/mock_solicitud_rutina_repository.dart';

void main() {
  group('Inicialización de Entorno (main.dart)', () {
    setUpAll(() async {
      await dotenv.load(fileName: '.env');
    });

    test('dotenv debe cargar las variables de entorno requeridas', () {
      // Arrange: setUpAll ya ejecutó dotenv.load()

      // Act
      final tieneUrl = dotenv.env.containsKey('SUPABASE_URL');
      final tieneKey = dotenv.env.containsKey('SUPABASE_ANON_KEY');

      // Assert
      expect(dotenv.isInitialized, isTrue);
      expect(tieneUrl, isTrue, reason: 'Falta SUPABASE_URL en el archivo .env');
      expect(
        tieneKey,
        isTrue,
        reason: 'Falta SUPABASE_ANON_KEY en el archivo .env',
      );
    });

    testWidgets('MyApp debe montar correctamente con dependencias mockeadas', (
      WidgetTester tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      final widget = ProviderScope(
        overrides: [
          exerciseRepositoryProvider.overrideWithValue(
            MockExerciseRepository(),
          ),
          routineRepositoryProvider.overrideWithValue(MockRoutineRepository()),
          alumnoRepositoryProvider.overrideWithValue(
            MockAlumnoRepository(),
          ), // ✅
          categoryExerciseRepositoryProvider.overrideWithValue(
            MockCategoryExerciseRepository(),
          ),
          solicitudRutinaRepositoryProvider.overrideWithValue(
            MockSolicitudRutinaRepository(),
          ),
        ],
        child: const MyApp(),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
