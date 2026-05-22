import 'package:flutter_test/flutter_test.dart';
// Importamos tu nuevo modelo de producción
import 'package:le_groupe_gym/data/models/exercise_model.dart'; 

void main() {
  group('Ejercicio Model Tests', () {
    test('Debe parsear correctamente el JSON de Supabase a objeto Ejercicio', () {
      // 1. ARRANGEMENT
      final Map<String, dynamic> jsonMock = {
        'id_ejercicio': 42,
        'nombre': 'Sentadilla profunda con barra',
        'Rel_Ejercicio_Categoria': [
          {
            'Categorias_Ejercicio': {
              'id_categoria': 3,
              'nombre': 'Piernas',
              'tipo': 'grupo_muscular'
            }
          },
          {
            'Categorias_Ejercicio': {
              'id_categoria': 15,
              'nombre': 'Cuádriceps',
              'tipo': 'subgrupo'
            }
          }
        ]
      };

      // 2. ACT
      final ejercicio = Ejercicio.fromJson(jsonMock);

      // 3. ASSERT
      expect(ejercicio.idEjercicio, 42);
      expect(ejercicio.nombre, 'Sentadilla profunda con barra');
      expect(ejercicio.categorias.length, 2);
      
      // Validamos el primer mapeo de categoría anidada
      expect(ejercicio.categorias[0].idCategoria, 3);
      expect(ejercicio.categorias[0].nombre, 'Piernas');
      expect(ejercicio.categorias[0].tipo, 'grupo_muscular');

      // Validamos el segundo mapeo
      expect(ejercicio.categorias[1].idCategoria, 15);
      expect(ejercicio.categorias[1].nombre, 'Cuádriceps');
      expect(ejercicio.categorias[1].tipo, 'subgrupo');
    });
  });
}