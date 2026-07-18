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
        'peso': '',
        'notas': 'Controlar la bajada',
      };
    });

    test(
      'copyWith debe permitir modificar un solo campo manteniendo el resto intacto',
      () {
        final original = EjercicioRutina(
          ejercicio: mockEjercicio,
          series: 4,
          repeticiones: '10',
        );

        // Clonamos modificando solo las repeticiones
        final clon = original.copyWith(repeticiones: '12');

        expect(clon.series, 4); // Se mantiene
        expect(clon.repeticiones, '12'); // Cambió
        expect(clon.ejercicio.nombre, 'Press de Banca Plano');
      },
    );

    test('fromMap debe construir la instancia correctamente', () {
      final resultado = EjercicioRutina.fromMap(jsonMock, mockEjercicio);

      expect(resultado.series, 4);
      expect(resultado.repeticiones, '12');
      expect(resultado.peso, '');
      expect(resultado.notas, 'Controlar la bajada');
    });

    test(
      'toMap debe exportar un mapa con la estructura correcta para la BD',
      () {
        final objeto = EjercicioRutina(
          ejercicio: mockEjercicio,
          series: 3,
          repeticiones: '8',
          peso: '',
          notas: 'Sin fallar',
        );

        final mapa = objeto.toMap();

        expect(mapa['series'], 3);
        expect(mapa['repeticiones'], '8');
        expect(mapa['peso'], '');
        expect(mapa['notas'], 'Sin fallar');
      },
    );
  });

  group('EjercicioRutina Model Tests - Superseries (Combo)', () {
    late Ejercicio ejercicioPrincipal;
    late Ejercicio ejercicioSecundario;
    late Ejercicio ejercicioTercero;

    setUp(() {
      ejercicioPrincipal = Ejercicio(
        idEjercicio: 1,
        nombre: 'Press de Banca',
        categorias: [],
      );
      ejercicioSecundario = Ejercicio(
        idEjercicio: 2,
        nombre: 'Aperturas con Mancuernas',
        categorias: [],
      );
      ejercicioTercero = Ejercicio(
        idEjercicio: 3,
        nombre: 'Fondos en Paralelas',
        categorias: [],
      );
    });

    test(
      'debe permitir combinar un segundo ejercicio con parámetros independientes',
      () {
        // Arrange
        final item = EjercicioRutina(
          ejercicio: ejercicioPrincipal,
          series: 4,
          repeticiones: '10',
          notas: 'Principal',
        );

        // Act
        item.combinarCon(
          ejercicioSecundario,
          series: 3,
          repeticiones: '15',
          notas: 'Secundario',
        );

        // Assert
        expect(item.esSuperserie, isTrue);
        expect(item.cantidadEjercicios, 2);
        expect(item.miembros[0].ejercicio.idEjercicio, 1);
        expect(item.miembros[0].series, 4);
        expect(item.miembros[0].repeticiones, '10');
        expect(item.miembros[0].notas, 'Principal');
        expect(item.miembros[1].ejercicio.idEjercicio, 2);
        expect(item.miembros[1].series, 3);
        expect(item.miembros[1].repeticiones, '15');
        expect(item.miembros[1].notas, 'Secundario');
        expect(item.ejercicio.idEjercicio, 1);
        expect(item.series, 4);
        expect(item.repeticiones, '10');
      },
    );

    test('no debe permitir combinar un tercer ejercicio (límite máximo 2)', () {
      // Arrange
      final item = EjercicioRutina(ejercicio: ejercicioPrincipal);
      item.combinarCon(ejercicioSecundario);

      // Act + Assert
      expect(
        () => item.combinarCon(ejercicioTercero),
        throwsA(isA<LimiteSuperserieException>()),
      );
      expect(item.cantidadEjercicios, 2);
    });

    test('actualizarMiembro debe modificar solo el slot indicado', () {
      // Arrange
      final item = EjercicioRutina(
        ejercicio: ejercicioPrincipal,
        series: 4,
        repeticiones: '10',
      );
      item.combinarCon(ejercicioSecundario, series: 3, repeticiones: '12');

      // Act
      item.actualizarMiembro(
        1,
        series: 5,
        repeticiones: '8',
        notas: 'Al fallo',
      );

      // Assert
      expect(item.miembros[0].series, 4);
      expect(item.miembros[0].repeticiones, '10');
      expect(item.miembros[1].series, 5);
      expect(item.miembros[1].repeticiones, '8');
      expect(item.miembros[1].notas, 'Al fallo');
    });
  });
}
