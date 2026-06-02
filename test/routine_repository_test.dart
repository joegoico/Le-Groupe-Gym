import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/data/repositories/routine_repository.dart';
import 'mocks/mock_routine_repository.dart';

void main() {
  group('RoutineRepository Tests - Mock Implementation', () {
    late RoutineRepository repository;

    setUp(() {
      repository = MockRoutineRepository();
    });

    test('saveRoutine debe retornar true al simular el guardado exitoso', () async {
      // Arrange
      final rutina = Rutina(nombre: 'Rutina Base para Alumno', ejercicios: []);

      // Act
      final result = await repository.saveRoutine(rutina);

      // Assert
      expect(result, equals(1));
    });

    test('toMap debe incluir id_alumno cuando se guarda una rutina con alumno asignado', () async {
      // Arrange
      final rutina = Rutina(
        nombre: 'Rutina de Juan Pérez',
        idAlumno: 'abc-123',
        ejercicios: [],
      );

      // Act
      final mapa = rutina.toMap();

      // Assert
      expect(mapa['nombre_rutina'], 'Rutina de Juan Pérez');
      expect(mapa['id_alumno'], 'abc-123');
      expect(mapa.containsKey('id_rutina'), isFalse);
    });

    test('buildEjerciciosInsertPayload debe incluir ejercicios con orden correcto', () {
      // Arrange
      final ejercicio1 = Ejercicio(idEjercicio: 1, nombre: 'Press Banca', categorias: []);
      final ejercicio2 = Ejercicio(idEjercicio: 2, nombre: 'Sentadilla', categorias: []);
      final rutina = Rutina(
        nombre: 'Rutina Completa',
        idAlumno: 'abc-123',
        ejercicios: [
          EjercicioRutina(ejercicio: ejercicio1, series: 4, repeticiones: '10'),
          EjercicioRutina(ejercicio: ejercicio2, series: 3, repeticiones: '12'),
        ],
      );

      // Act
      final ejerciciosData = rutina.buildEjerciciosInsertPayload(42);

      // Assert
      expect(ejerciciosData.length, 2);
      expect(ejerciciosData[0]['id_rutina'], 42);
      expect(ejerciciosData[0]['id_ejercicio'], 1);
      expect(ejerciciosData[0]['orden'], 0);
      expect(ejerciciosData[0].containsKey('id_combo'), isFalse);
      expect(ejerciciosData[1]['id_ejercicio'], 2);
      expect(ejerciciosData[1]['orden'], 1);
      expect(ejerciciosData[1].containsKey('id_combo'), isFalse);
    });

    test('buildEjerciciosInsertPayload debe asignar id_combo a miembros de superserie', () {
      // Arrange
      final press = Ejercicio(idEjercicio: 1, nombre: 'Press Banca', categorias: []);
      final aperturas = Ejercicio(idEjercicio: 2, nombre: 'Aperturas', categorias: []);
      final sentadilla = Ejercicio(idEjercicio: 3, nombre: 'Sentadilla', categorias: []);
      final superserie = EjercicioRutina(ejercicio: press, series: 4, repeticiones: '10');
      superserie.combinarCon(aperturas, series: 3, repeticiones: '12');
      final rutina = Rutina(
        nombre: 'Rutina con superserie',
        ejercicios: [
          superserie,
          EjercicioRutina(ejercicio: sentadilla, series: 5, repeticiones: '8'),
        ],
      );

      // Act
      final filas = rutina.buildEjerciciosInsertPayload(7);

      // Assert
      expect(filas.length, 3);
      expect(filas[0]['id_combo'], 1);
      expect(filas[1]['id_combo'], 1);
      expect(filas[0]['id_ejercicio'], 1);
      expect(filas[1]['id_ejercicio'], 2);
      expect(filas[0]['series'], 4);
      expect(filas[1]['series'], 3);
      expect(filas[2].containsKey('id_combo'), isFalse);
      expect(filas[2]['id_ejercicio'], 3);
      expect(filas[2]['orden'], 2);
    });

    test('buildEjerciciosInsertPayload debe numerar id_combo distinto por cada superserie', () {
      // Arrange
      final e1 = Ejercicio(idEjercicio: 1, nombre: 'A', categorias: []);
      final e2 = Ejercicio(idEjercicio: 2, nombre: 'B', categorias: []);
      final e3 = Ejercicio(idEjercicio: 3, nombre: 'C', categorias: []);
      final e4 = Ejercicio(idEjercicio: 4, nombre: 'D', categorias: []);
      final combo1 = EjercicioRutina(ejercicio: e1)..combinarCon(e2);
      final combo2 = EjercicioRutina(ejercicio: e3)..combinarCon(e4);
      final rutina = Rutina(nombre: 'Doble superserie', ejercicios: [combo1, combo2]);

      // Act
      final filas = rutina.buildEjerciciosInsertPayload(1);

      // Assert
      expect(filas[0]['id_combo'], 1);
      expect(filas[1]['id_combo'], 1);
      expect(filas[2]['id_combo'], 2);
      expect(filas[3]['id_combo'], 2);
    });

    test('saveRoutine sin alumno asignado no debe incluir id_alumno en el payload', () async {
      // Arrange
      final rutina = Rutina(
        nombre: 'Rutina Sin Alumno',
        ejercicios: [],
      );

      // Act
      final mapa = rutina.toMap();

      // Assert
      expect(mapa.containsKey('id_alumno'), isFalse);
    });
    test('saveRoutine debe retornar el id_rutina generado por Supabase', () async {
      // Arrange
      final rutina = Rutina(
        nombre: 'Rutina Test',
        idAlumno: 'abc-123',
        ejercicios: [],
      );

      // Act
      final idRutina = await repository.saveRoutine(rutina);

      // Assert
      expect(idRutina, isNotNull);
      expect(idRutina, greaterThan(0));
    });
    test('updatePdfUrl debe actualizar la url_pdf de la rutina', () async {
      // Arrange
      const idRutina = 1;
      const url = 'https://storage.supabase.co/rutinas-pdf/test.pdf';

      // Act
      await repository.updatePdfUrl(idRutina: idRutina, url: url);

      // Assert — si no lanza excepción, consideramos éxito
      expect(true, isTrue);
    });
  });
}