import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';

void main() {
  group('CategoriaEjercicio Model Tests - Completo', () {
    test('Debe instanciar correctamente desde el constructor base', () {
      final categoria = CategoriaEjercicio(
        idCategoria: 1,
        nombre: 'Pecho',
        tipo: 'grupo_muscular',
      );

      expect(categoria.idCategoria, 1);
      expect(categoria.nombre, 'Pecho');
      expect(categoria.tipo, 'grupo_muscular');
    });

    test(
      'fromJson debe mapear correctamente las llaves snake_case de Supabase',
      () {
        final jsonMock = {
          'id_categoria': 15,
          'nombre': 'Hipertrofia',
          'tipo': 'modalidad',
        };

        final categoria = CategoriaEjercicio.fromJson(jsonMock);

        expect(categoria.idCategoria, 15);
        expect(categoria.nombre, 'Hipertrofia');
        expect(categoria.tipo, 'modalidad');
      },
    );

    // ==========================================
    // NUEVOS TESTS: copyWith y toMap
    // ==========================================
    test('copyWith debe permitir clonar modificando atributos específicos', () {
      final original = CategoriaEjercicio(
        idCategoria: 2,
        nombre: 'Piernas',
        tipo: 'grupo_muscular',
      );

      final clon = original.copyWith(nombre: 'Tren Inferior');

      expect(clon.idCategoria, 2); // Se mantiene intacto
      expect(clon.nombre, 'Tren Inferior'); // Se actualizó
      expect(clon.tipo, 'grupo_muscular'); // Se mantiene intacto
    });

    test(
      'toMap debe exportar la estructura correcta para inserciones en Supabase',
      () {
        final categoria = CategoriaEjercicio(
          idCategoria: 5,
          nombre: 'Fuerza',
          tipo: 'disciplina',
        );

        final mapa = categoria.toMap();

        expect(mapa['id_categoria'], 5);
        expect(mapa['nombre'], 'Fuerza');
        expect(mapa['tipo'], 'disciplina');
      },
    );
    test('debe instanciar con id_categoria_padre nulo por defecto', () {
      // Arrange + Act
      final categoria = CategoriaEjercicio(
        idCategoria: 3,
        nombre: 'Pectoral Mayor',
        tipo: 'subgrupo',
      );

      // Assert
      expect(categoria.idCategoriaPadre, isNull);
    });

    test('fromJson debe mapear id_categoria_padre cuando existe', () {
      // Arrange
      final jsonMock = {
        'id_categoria': 3,
        'nombre': 'Pectoral Mayor',
        'tipo': 'subgrupo',
        'id_categoria_padre': 1,
      };

      // Act
      final categoria = CategoriaEjercicio.fromJson(jsonMock);

      // Assert
      expect(categoria.idCategoriaPadre, 1);
    });

    test('fromJson debe mapear id_categoria_padre como nulo si no existe', () {
      // Arrange
      final jsonMock = {
        'id_categoria': 1,
        'nombre': 'Pecho',
        'tipo': 'grupo_muscular',
      };

      // Act
      final categoria = CategoriaEjercicio.fromJson(jsonMock);

      // Assert
      expect(categoria.idCategoriaPadre, isNull);
    });

    test('toMap debe incluir id_categoria_padre cuando está definido', () {
      // Arrange
      final categoria = CategoriaEjercicio(
        idCategoria: 3,
        nombre: 'Pectoral Mayor',
        tipo: 'subgrupo',
        idCategoriaPadre: 1,
      );

      // Act
      final mapa = categoria.toMap();

      // Assert
      expect(mapa['id_categoria_padre'], 1);
    });
  });
}
