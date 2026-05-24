import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';

void main() {
  group('EjercicioRutina Model Tests - Serialización y Clón', () {
    late Ejercicio mockEjercicio;
    late Map<String, dynamic> jsonMock;

    setUp(() {
      mockEjercicio = Ejercicio(
        idEjercicio: 1,
        nombre: 'Press de Banca Plano',
        categorias: [],
      );

      // Estructura típica que vendría de una tabla relacional o payload JSON
      jsonMock = {
        'series': 4,
        'repeticiones': '12',
        'descanso': '90',
        'notas': 'Controlar la bajada',
      };
    });

    test('copyWith debe permitir modificar un solo campo manteniendo el resto intacto', () {
      final original = EjercicioRutina(ejercicio: mockEjercicio, series: 4, repeticiones: '10');
      
      // Clonamos modificando solo las repeticiones
      final clon = original.copyWith(repeticiones: '12');

      expect(clon.series, 4); // Se mantiene
      expect(clon.repeticiones, '12'); // Cambió
      expect(clon.ejercicio.nombre, 'Press de Banca Plano');
    });

    test('fromMap debe construir la instancia correctamente', () {
      final resultado = EjercicioRutina.fromMap(jsonMock, mockEjercicio);

      expect(resultado.series, 4);
      expect(resultado.repeticiones, '12');
      expect(resultado.descanso, '90');
      expect(resultado.notas, 'Controlar la bajada');
    });

    test('toMap debe exportar un mapa con la estructura correcta para la BD', () {
      final objeto = EjercicioRutina(
        ejercicio: mockEjercicio,
        series: 3,
        repeticiones: '8',
        descanso: '60',
        notas: 'Sin fallar',
      );

      final mapa = objeto.toMap();

      expect(mapa['series'], 3);
      expect(mapa['repeticiones'], '8');
      expect(mapa['descanso'], '60');
      expect(mapa['notas'], 'Sin fallar');
    });
  });
}
