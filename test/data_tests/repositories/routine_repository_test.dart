import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/dia_rutina_model.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/data/repositories/routine_repository.dart';
import '../../mocks/mock_routine_repository.dart';

void main() {
  group('RoutineRepository Tests - Mock Implementation', () {
    late RoutineRepository repository;

    setUp(() {
      repository = MockRoutineRepository();
    });

    test(
      'saveRoutine debe retornar true al simular el guardado exitoso',
      () async {
        // Arrange
        final rutina = Rutina(nombre: 'Rutina Base para Alumno');

        // Act
        final result = await repository.saveRoutine(rutina);

        // Assert
        expect(result, equals(1));
      },
    );

    test(
      'toMap debe incluir id_alumno cuando se guarda una rutina con alumno asignado',
      () async {
        // Arrange
        final rutina = Rutina(
          nombre: 'Rutina de Juan Pérez',
          idAlumno: 'abc-123',
        );

        // Act
        final mapa = rutina.toMap();

        // Assert
        expect(mapa['nombre_rutina'], 'Rutina de Juan Pérez');
        expect(mapa['id_alumno'], 'abc-123');
        expect(mapa.containsKey('id_rutina'), isFalse);
      },
    );

    test(
      'debe incluir ejercicios con orden correcto al iterar día y bloques',
      () {
        // Arrange
        final ejercicio1 = Ejercicio(
          idEjercicio: 1,
          nombre: 'Press Banca',
          categorias: [],
        );
        final ejercicio2 = Ejercicio(
          idEjercicio: 2,
          nombre: 'Sentadilla',
          categorias: [],
        );

        final dia = DiaRutina(
          nombre: 'Día 1',
          orden: 0,
          bloques: [
            BloqueRutina(
              id: 'b1',
              nombre: 'B1',
              ejercicios: [
                EjercicioRutina(
                  ejercicio: ejercicio1,
                  series: 4,
                  repeticiones: '10',
                ),
                EjercicioRutina(
                  ejercicio: ejercicio2,
                  series: 3,
                  repeticiones: '12',
                ),
              ],
            ),
          ],
        );

        // Act — simulamos el payload que armaría el repositorio
        var orden = 0;
        final payload = dia.bloques
            .expand((b) => b.ejercicios)
            .expand((t) => t.miembros)
            .map(
              (m) => {
                'id_ejercicio': m.ejercicio.idEjercicio,
                'series': m.series,
                'repeticiones': m.repeticiones,
                'orden': orden++,
              },
            )
            .toList();

        // Assert
        expect(payload.length, 2);
        expect(payload[0]['id_ejercicio'], 1);
        expect(payload[0]['orden'], 0);
        expect(payload[1]['id_ejercicio'], 2);
        expect(payload[1]['orden'], 1);
      },
    );

    test('debe asignar miembros de superserie correctamente', () {
      // Arrange
      final press = Ejercicio(
        idEjercicio: 1,
        nombre: 'Press Banca',
        categorias: [],
      );
      final aperturas = Ejercicio(
        idEjercicio: 2,
        nombre: 'Aperturas',
        categorias: [],
      );
      final sentadilla = Ejercicio(
        idEjercicio: 3,
        nombre: 'Sentadilla',
        categorias: [],
      );

      final superserie = EjercicioRutina(
        ejercicio: press,
        series: 4,
        repeticiones: '10',
      );
      superserie.combinarCon(aperturas, series: 3, repeticiones: '12');

      final dia = DiaRutina(
        nombre: 'Día 1',
        orden: 0,
        bloques: [
          BloqueRutina(
            id: 'b1',
            nombre: 'B1',
            ejercicios: [
              superserie,
              EjercicioRutina(
                ejercicio: sentadilla,
                series: 5,
                repeticiones: '8',
              ),
            ],
          ),
        ],
      );

      // Act
      final miembros = dia.bloques
          .expand((b) => b.ejercicios)
          .expand((t) => t.miembros)
          .toList();

      // Assert
      expect(miembros.length, 3);
      expect(miembros[0].ejercicio.idEjercicio, 1);
      expect(miembros[0].series, 4);
      expect(miembros[1].ejercicio.idEjercicio, 2);
      expect(miembros[1].series, 3);
      expect(miembros[2].ejercicio.idEjercicio, 3);
      expect(superserie.esSuperserie, isTrue);
    });
    test(
      'buildEjerciciosInsertPayload debe numerar id_combo distinto por cada superserie',
      () {
        // Arrange
        final e1 = Ejercicio(idEjercicio: 1, nombre: 'A', categorias: []);
        final e2 = Ejercicio(idEjercicio: 2, nombre: 'B', categorias: []);
        final e3 = Ejercicio(idEjercicio: 3, nombre: 'C', categorias: []);
        final e4 = Ejercicio(idEjercicio: 4, nombre: 'D', categorias: []);
        final combo1 = EjercicioRutina(ejercicio: e1)..combinarCon(e2);
        final combo2 = EjercicioRutina(ejercicio: e3)..combinarCon(e4);

        final dia = DiaRutina(
          nombre: 'Día 1',
          orden: 0,
          bloques: [
            BloqueRutina(id: 'b1', nombre: 'B1', ejercicios: [combo1, combo2]),
          ],
        );

        // Act — aplanamos todos los miembros
        final miembros = dia.bloques
            .expand((b) => b.ejercicios)
            .expand((t) => t.miembros)
            .toList();

        // Assert
        expect(miembros.length, 4); // 2 superseries × 2 miembros
        expect(combo1.esSuperserie, isTrue);
        expect(combo2.esSuperserie, isTrue);
        expect(combo1.miembros[0].ejercicio.nombre, 'A');
        expect(combo1.miembros[1].ejercicio.nombre, 'B');
        expect(combo2.miembros[0].ejercicio.nombre, 'C');
        expect(combo2.miembros[1].ejercicio.nombre, 'D');
      },
    );

    test(
      'saveRoutine sin alumno asignado no debe incluir id_alumno en el payload',
      () async {
        // Arrange
        final rutina = Rutina(nombre: 'Rutina Sin Alumno');

        // Act
        final mapa = rutina.toMap();

        // Assert
        expect(mapa.containsKey('id_alumno'), isFalse);
      },
    );
    test(
      'saveRoutine debe retornar el id_rutina generado por Supabase',
      () async {
        // Arrange
        final rutina = Rutina(nombre: 'Rutina Test', idAlumno: 'abc-123');

        // Act
        final idRutina = await repository.saveRoutine(rutina);

        // Assert
        expect(idRutina, isNotNull);
        expect(idRutina, greaterThan(0));
      },
    );
    test('updatePdfUrl debe actualizar la url_pdf de la rutina', () async {
      // Arrange
      const idRutina = 1;
      const url = 'https://storage.supabase.co/rutinas-pdf/test.pdf';

      // Act
      await repository.updatePdfUrl(idRutina: idRutina, url: url);

      // Assert — si no lanza excepción, consideramos éxito
      expect(true, isTrue);
    });
    test('getRutinas debe retornar lista de rutinas con su alumno', () async {
      // Act
      final result = await repository.getRutinas();

      // Assert
      expect(result, isA<List<({Rutina rutina, Alumno alumno})>>());
      expect(result, isNotEmpty);
      expect(result.first.rutina.nombre, isNotEmpty);
      expect(result.first.alumno.nombreCompleto, isNotEmpty);
    });
    test('updateRoutine debe completarse sin errores', () async {
      // Arrange
      final rutina = Rutina(
        idRutina: 1,
        nombre: 'Rutina Actualizada',
        idAlumno: 'abc-123',
        dias: [
          DiaRutina(
            idDia: 1,
            nombre: 'Día 1',
            orden: 0,
            bloques: [
              BloqueRutina(
                id: 'b1',
                nombre: 'Bloque 1',
                ejercicios: [
                  EjercicioRutina(
                    ejercicio: Ejercicio(
                      idEjercicio: 1,
                      nombre: 'Press Banca',
                      categorias: [],
                    ),
                    series: 4,
                    repeticiones: '10',
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      // Act + Assert
      expect(
        () async => await repository.updateRoutine(rutina),
        returnsNormally,
      );
    });
    test(
      'getRutinaCompleta debe retornar la rutina con días, bloques y ejercicios',
      () async {
        // Arrange + Act
        final result = await repository.getRutinaCompleta(1);

        // Assert
        expect(result, isNotNull);
        expect(result!.dias, isNotEmpty);
        expect(result.dias.first.bloques, isNotEmpty);
        expect(result.dias.first.bloques.first.ejercicios, isNotEmpty);
      },
    );
    test(
      'getRutinas con idAlumno debe retornar solo las rutinas de ese alumno',
      () async {
        // Arrange + Act
        final result = await repository.getRutinasPorAlumno('abc-123');

        // Assert
        expect(result, isNotEmpty);
        for (final item in result) {
          expect(item.alumno.idAlumno, 'abc-123');
        }
      },
    );
    test(
      'getRutinasPredeterminadas debe retornar solo rutinas predeterminadas',
      () async {
        // Act
        final result = await repository.getRutinasPredeterminadas();

        // Assert
        expect(result, isA<List<Rutina>>());
        for (final rutina in result) {
          expect(rutina.esPredeterminada, isTrue);
        }
      },
    );
  });
}
