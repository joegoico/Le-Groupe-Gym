import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';

void main() {
  group('Ejercicio Model Tests - Dependencia Intermedia', () {
    test('Debe instanciar correctamente desde el constructor base', () {
      final ejercicio = Ejercicio(idEjercicio: 1, nombre: 'Dominadas', categorias: []);
      
      expect(ejercicio.idEjercicio, 1);
      expect(ejercicio.nombre, 'Dominadas');
      expect(ejercicio.categorias, isEmpty);
    });

    test('fromJson debe mapear correctamente la estructura relacional anidada de Supabase', () {
      // Simulamos la respuesta exacta de un JOIN de Supabase
      final jsonMock = {
        'id_ejercicio': 10,
        'nombre': 'Press Militar',
        'Rel_Ejercicio_Categoria': [
          {
            'Categorias_Ejercicio': {
              'id_categoria': 3,
              'nombre': 'Hombros',
              'tipo': 'grupo_muscular'
            }
          }
        ]
      };

      final ejercicio = Ejercicio.fromJson(jsonMock);

      expect(ejercicio.idEjercicio, 10);
      expect(ejercicio.nombre, 'Press Militar');
      expect(ejercicio.categorias.length, 1);
      expect(ejercicio.categorias.first.nombre, 'Hombros');
    });

    test('copyWith debe permitir clonar modificando atributos específicos', () {
      final original = Ejercicio(idEjercicio: 1, nombre: 'Remo', categorias: []);
      
      final clon = original.copyWith(nombre: 'Remo en Polea');

      expect(clon.idEjercicio, 1);
      expect(clon.nombre, 'Remo en Polea');
    });

    test('toMap debe exportar solo la tabla base para inserciones', () {
      final ejercicio = Ejercicio(idEjercicio: 5, nombre: 'Vuelos Laterales', categorias: []);
      
      final mapa = ejercicio.toMap();

      expect(mapa['id_ejercicio'], 5);
      expect(mapa['nombre'], 'Vuelos Laterales');
      expect(mapa.containsKey('categorias'), isFalse); // Las relaciones van en otra tabla
    });
  });
}