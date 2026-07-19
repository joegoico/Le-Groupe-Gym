import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/data/models/dia_rutina_model.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';

void main() {
  group('Rutina Model Tests - Completo', () {
    late EjercicioRutina mockEjercicioRutina;

    setUp(() {
      final mockEjercicio = Ejercicio(
        idEjercicio: 1,
        nombre: 'Press de Banca Plano',
        categorias: [
          CategoriaEjercicio(
            idCategoria: 1,
            nombre: 'Pecho',
            tipo: 'grupo_muscular',
          ),
        ],
      );
      mockEjercicioRutina = EjercicioRutina(
        ejercicio: mockEjercicio,
        series: 4,
        repeticiones: '10',
      );
    });
    test('toMap debe incluir id_alumno cuando está presente', () {
      // Arrange
      final rutina = Rutina(nombre: 'Día 1 - Empuje', idAlumno: 'abc-123');

      // Act
      final mapa = rutina.toMap();

      // Assert
      expect(mapa['id_alumno'], 'abc-123');
    });

    test('toMap no debe incluir id_alumno cuando es nulo', () {
      // Arrange
      final rutina = Rutina(
        nombre: 'Día 1 - Empuje',
        // idAlumno no se pasa → queda null
      );

      // Act
      final mapa = rutina.toMap();

      // Assert
      expect(mapa.containsKey('id_alumno'), isFalse);
    });

    test('Debe instanciar una Rutina completa correctamente', () {
      // Arrange + Act
      final rutina = Rutina(
        idRutina: 100,
        nombre: 'Día 1 - Fuerza Pecho y Triceps',
        dias: [
          DiaRutina(
            nombre: 'Día 1',
            orden: 0,
            bloques: [
              BloqueRutina(
                id: 'b1',
                nombre: 'Bloque 1',
                ejercicios: [mockEjercicioRutina],
              ),
            ],
          ),
        ],
      );

      // Assert
      expect(rutina.idRutina, 100);
      expect(rutina.nombre, 'Día 1 - Fuerza Pecho y Triceps');
      expect(rutina.ejercicios.length, 1); // getter de compatibilidad
      expect(rutina.ejercicios.first.ejercicio.nombre, 'Press de Banca Plano');
    });

    test(
      'toMap debe exportar con la clave nombre_rutina que usa la tabla de Supabase',
      () {
        // Arrange
        final rutina = Rutina(idRutina: 10, nombre: 'Día 1 - Empuje');

        // Act
        final mapa = rutina.toMap();

        // Assert
        expect(mapa['id_rutina'], 10);
        expect(
          mapa['nombre_rutina'],
          'Día 1 - Empuje',
        ); // ✅ clave real de la BD
        expect(
          mapa.containsKey('nombre'),
          isFalse,
        ); // ✅ la clave vieja no debe existir
      },
    );

    test('fromMap debe reconstruir la Rutina desde la cabecera de la BD', () {
      // Arrange
      final jsonMock = {
        'id_rutina': 42,
        'nombre_rutina': 'Circuito de Piernas',
      };
      final diaConEjercicios = DiaRutina(
        nombre: 'Día 1',
        orden: 0,
        bloques: [
          BloqueRutina(
            id: 'b1',
            nombre: 'Bloque 1',
            ejercicios: [mockEjercicioRutina],
          ),
        ],
      );

      // Act
      final resultado = Rutina.fromMap(jsonMock, dias: [diaConEjercicios]);

      // Assert
      expect(resultado.idRutina, 42);
      expect(resultado.nombre, 'Circuito de Piernas');
      expect(resultado.ejercicios.length, 1);
      expect(resultado.ejercicios.first.series, 4);
    });

    test('copyWith debe permitir clonar modificando atributos específicos', () {
      // Arrange
      final original = Rutina(idRutina: 1, nombre: 'Rutina A');

      // Act
      final clon = original.copyWith(nombre: 'Rutina B (Actualizada)');

      // Assert
      expect(clon.idRutina, 1);
      expect(clon.nombre, 'Rutina B (Actualizada)');
    });
    test('fromMap debe mapear url_pdf cuando existe', () {
      // Arrange
      final jsonMock = {
        'id_rutina': 1,
        'nombre_rutina': 'Rutina Test',
        'url_pdf': 'https://storage.supabase.co/rutinas/1.pdf',
      };

      // Act
      final rutina = Rutina.fromMap(jsonMock);

      // Assert
      expect(rutina.urlPdf, 'https://storage.supabase.co/rutinas/1.pdf');
    });

    test('fromMap debe mapear url_pdf como null cuando no existe', () {
      // Arrange
      final jsonMock = {'id_rutina': 1, 'nombre_rutina': 'Rutina Test'};

      // Act
      final rutina = Rutina.fromMap(jsonMock);

      // Assert
      expect(rutina.urlPdf, isNull);
    });
  });
}
