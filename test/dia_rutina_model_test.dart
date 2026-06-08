import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/dia_rutina_model.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';

void main() {
  group('DiaRutina Model Tests', () {
    test('debe instanciar un DiaRutina correctamente', () {
      // Arrange + Act
      final dia = DiaRutina(nombre: 'Día 1 - Pecho', orden: 0);

      // Assert
      expect(dia.nombre, 'Día 1 - Pecho');
      expect(dia.orden, 0);
      expect(dia.bloques, isEmpty);
      expect(dia.idDia, isNull);
    });

    test('debe instanciar con bloques', () {
      // Arrange + Act
      final dia = DiaRutina(
        nombre: 'Día 2 - Espalda',
        orden: 1,
        bloques: [BloqueRutina(id: '1', nombre: 'Bloque 1')],
      );

      // Assert
      expect(dia.bloques.length, 1);
    });

    test('toMap debe exportar la estructura correcta para Supabase', () {
      // Arrange
      final dia = DiaRutina(idDia: 1, nombre: 'Día 1 - Pecho', orden: 0);

      // Act
      final mapa = dia.toMap(idRutina: 10);

      // Assert
      expect(mapa['nombre_dia'], 'Día 1 - Pecho');
      expect(mapa['orden'], 0);
      expect(mapa['id_rutina'], 10);
      expect(mapa.containsKey('id_dia'), isFalse);
    });

    test('fromMap debe reconstruir un DiaRutina desde Supabase', () {
      // Arrange
      final jsonMock = {
        'id_dia': 5,
        'nombre_dia': 'Día 3 - Piernas',
        'orden': 2,
        'id_rutina': 10,
      };

      // Act
      final dia = DiaRutina.fromMap(jsonMock);

      // Assert
      expect(dia.idDia, 5);
      expect(dia.nombre, 'Día 3 - Piernas');
      expect(dia.orden, 2);
    });

    test('copyWith debe clonar modificando atributos específicos', () {
      // Arrange
      final original = DiaRutina(nombre: 'Día 1', orden: 0);

      // Act
      final clon = original.copyWith(nombre: 'Día 1 - Pecho');

      // Assert
      expect(clon.nombre, 'Día 1 - Pecho');
      expect(clon.orden, 0);
    });

    test('estaVacio debe ser true si no tiene bloques con ejercicios', () {
      // Arrange
      final dia = DiaRutina(nombre: 'Día 1', orden: 0);

      // Assert
      expect(dia.estaVacio, isTrue);
    });
  });
}
