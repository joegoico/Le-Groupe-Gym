import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';

void main() {
  group('Bloques de rutina - modelo y payload', () {
    test('Rutina con bloques debe aplanar ejercicios en orden', () {
      // Arrange
      final bloque1 = BloqueRutina(
        id: 'b1',
        nombre: 'Bloque 1',
        ejercicios: [
          EjercicioRutina(
            ejercicio: Ejercicio(idEjercicio: 1, nombre: 'A', categorias: []),
          ),
        ],
      );
      final bloque2 = BloqueRutina(
        id: 'b2',
        nombre: 'Bloque 2',
        ejercicios: [
          EjercicioRutina(
            ejercicio: Ejercicio(idEjercicio: 2, nombre: 'B', categorias: []),
          ),
        ],
      );
      final rutina = Rutina(nombre: 'R', bloques: [bloque1, bloque2]);

      // Act + Assert
      expect(rutina.ejercicios.length, 2);
      expect(rutina.ejercicios[0].ejercicio.nombre, 'A');
      expect(rutina.ejercicios[1].ejercicio.nombre, 'B');
    });

    test('buildEjerciciosInsertPayload recorre todos los bloques', () {
      // Arrange
      final superserie = EjercicioRutina(
        ejercicio: Ejercicio(idEjercicio: 1, nombre: 'Press', categorias: []),
      )..combinarCon(Ejercicio(idEjercicio: 2, nombre: 'Fly', categorias: []));

      final rutina = Rutina(
        nombre: 'R',
        bloques: [
          BloqueRutina(id: 'b1', nombre: 'B1', ejercicios: [superserie]),
          BloqueRutina(
            id: 'b2',
            nombre: 'B2',
            ejercicios: [
              EjercicioRutina(
                ejercicio: Ejercicio(idEjercicio: 3, nombre: 'Sentadilla', categorias: []),
              ),
            ],
          ),
        ],
      );

      // Act
      final filas = rutina.buildEjerciciosInsertPayload(10);

      // Assert
      expect(filas.length, 3);
      expect(filas[0]['id_combo'], 1);
      expect(filas[1]['id_combo'], 1);
      expect(filas[2].containsKey('id_combo'), isFalse);
    });
  });
}
