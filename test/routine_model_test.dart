import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';

void main() {
  group('Rutina Model Tests - Completo', () {
    late EjercicioRutina mockEjercicioRutina;

    setUp(() {
      // 1. Preparamos los datos base para componer una rutina
      final mockEjercicio = Ejercicio(
        idEjercicio: 1,
        nombre: 'Press de Banca Plano',
        categorias: [
          CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
        ],
      );
      
      mockEjercicioRutina = EjercicioRutina(
        ejercicio: mockEjercicio, 
        series: 4, 
        repeticiones: '10'
      );
    });

    test('Debe instanciar una Rutina completa correctamente', () {
      final rutina = Rutina(
        idRutina: 100,
        nombre: 'Día 1 - Fuerza Pecho y Triceps',
        ejercicios: [mockEjercicioRutina],
      );

      expect(rutina.idRutina, 100);
      expect(rutina.nombre, 'Día 1 - Fuerza Pecho y Triceps');
      expect(rutina.ejercicios.length, 1);
      expect(rutina.ejercicios.first.ejercicio.nombre, 'Press de Banca Plano');
    });

    test('toMap debe exportar la estructura correcta para la tabla de rutinas en Supabase', () {
      final rutina = Rutina(
        idRutina: 10,
        nombre: 'Día 1 - Empuje',
        ejercicios: [mockEjercicioRutina],
      );

      final mapa = rutina.toMap();

      expect(mapa['id_rutina'], 10);
      expect(mapa['nombre'], 'Día 1 - Empuje');
      // No debe exportar la lista de ejercicios porque eso se maneja en la tabla relacional intermedia
      expect(mapa.containsKey('ejercicios'), isFalse); 
    });

    test('fromMap debe reconstruir la Rutina desde la cabecera de la BD', () {
      final jsonMock = {
        'id_rutina': 42,
        'nombre': 'Circuito de Piernas',
      };

      // Simulamos que le inyectamos los ejercicios que trajimos de la tabla intermedia
      final resultado = Rutina.fromMap(jsonMock, ejercicios: [mockEjercicioRutina]);

      expect(resultado.idRutina, 42);
      expect(resultado.nombre, 'Circuito de Piernas');
      expect(resultado.ejercicios.length, 1);
      expect(resultado.ejercicios.first.series, 4);
    });

    test('copyWith debe permitir clonar modificando atributos específicos', () {
      final original = Rutina(
        idRutina: 1, 
        nombre: 'Rutina A', 
        ejercicios: [mockEjercicioRutina]
      );
      
      final clon = original.copyWith(nombre: 'Rutina B (Actualizada)');

      expect(clon.idRutina, 1); // Se mantiene intacto
      expect(clon.nombre, 'Rutina B (Actualizada)'); // Se actualizó
      expect(clon.ejercicios.length, 1); // Se mantiene intacto
    });
  });
}