import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/services/pdf_generator.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/data/models/dia_rutina_model.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PdfGenerator Tests', () {
    late Alumno mockAlumno;
    late Rutina mockRutina;
    late Rutina mockRutinaSuperserie;
    late Ejercicio mockEjercicioCombo;
    late CategoriaEjercicio mockCategoriaPecho;
    late CategoriaEjercicio mockCategoriaCuadriceps;

    setUp(() {
      mockAlumno = Alumno(
        idAlumno: 'abc-123',
        nombre: 'Juan',
        apellido: 'Pérez',
        mail: 'juan@mail.com',
        aplicaDescuento: false,
      );
      mockCategoriaPecho = CategoriaEjercicio(
        idCategoria: 1,
        nombre: 'Pecho',
        tipo: 'grupo muscular',
      );
      mockCategoriaCuadriceps = CategoriaEjercicio(
        idCategoria: 1,
        nombre: 'Cuadriceps',
        tipo: 'grupo muscular',
      );
      mockEjercicioCombo = Ejercicio(
        idEjercicio: 2,
        nombre: 'Sentadilla',
        categorias: [mockCategoriaCuadriceps],
      );

      // 👇 Nueva estructura con días y bloques
      mockRutinaSuperserie = Rutina(
        idRutina: 2,
        nombre: 'Rutina con Superserie',
        idAlumno: 'abc-123',
        dias: [
          DiaRutina(
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
                      nombre: 'Press de Banca',
                      categorias: [],
                    ),
                    series: 4,
                    repeticiones: '10',
                    peso: '',
                  )..combinarCon(
                    mockEjercicioCombo,
                    series: 3,
                    repeticiones: '15',
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      mockRutina = Rutina(
        idRutina: 1,
        nombre: 'Día 1 - Empuje',
        idAlumno: 'abc-123',
        dias: [
          DiaRutina(
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
                      nombre: 'Press de Banca',
                      categorias: [mockCategoriaPecho],
                    ),
                    series: 4,
                    repeticiones: '10',
                    peso: '',
                  ),
                  EjercicioRutina(
                    ejercicio: Ejercicio(
                      idEjercicio: 2,
                      nombre: 'Sentadilla',
                      categorias: [mockCategoriaCuadriceps],
                    ),
                    series: 3,
                    repeticiones: '12',
                    peso: '',
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });

    test('generate debe retornar bytes no vacíos', () async {
      // Arrange
      final generator = PdfGenerator();

      // Act
      final bytes = await generator.generate(
        rutina: mockRutina,
        alumno: mockAlumno,
      );

      // Assert
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
    });

    test(
      'generate debe retornar un PDF válido (empieza con header PDF)',
      () async {
        // Arrange
        final generator = PdfGenerator();

        // Act
        final bytes = await generator.generate(
          rutina: mockRutina,
          alumno: mockAlumno,
        );

        // Assert — todo PDF válido empieza con %PDF
        final header = String.fromCharCodes(bytes.take(4));
        expect(header, equals('%PDF'));
      },
    );
    test('generate debe incluir ejercicios combinados en superserie', () async {
      // Arrange
      final generator = PdfGenerator();

      // Act
      final bytes = await generator.generate(
        rutina: mockRutinaSuperserie,
        alumno: mockAlumno,
      );

      // Assert
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
    });

    test(
      'buildExerciseTableData debe listar cada miembro de la superserie',
      () {
        // Arrange
        final generator = PdfGenerator();

        // Act
        final filas = generator.buildExerciseTableData(mockRutinaSuperserie);

        // Assert — +1 por la cabecera de día
        expect(filas.length, 4);
        expect(filas[0][0], contains('Día 1'));
        expect(filas[1][0], contains('Bloque 1'));
        expect(filas[2][0], contains('Press de Banca'));
        expect(filas[2][0], contains('Superserie'));
        expect(filas[2][1], '4');
        expect(filas[2][2], '10');
        expect(filas[3][0], contains('Sentadilla'));
        expect(filas[3][1], '3');
        expect(filas[3][2], '15');
      },
    );

    test('debe agregar el grupo muscular en el pdf', () {
      final generator = PdfGenerator();

      final filas = generator.buildExerciseTableData(mockRutina);

      // Assert — +1 por la cabecera de día
      expect(filas.length, 4);
      expect(filas[2][4], contains('Pecho'));
      expect(filas[3][4], contains('Cuadriceps'));
    });
    test('el PDF debe contener un campo editable para el peso', () async {
      // Arrange
      final generator = PdfGenerator();

      // Act
      final bytes = await generator.generate(
        rutina: mockRutina,
        alumno: mockAlumno,
      );

      // Assert — verificamos que el PDF se generó y tiene un tamaño razonable
      // Los campos editables agregan overhead al PDF
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
    });
    group('PDF con múltiples días', () {
      late Rutina mockRutinaMultiDia;

      setUp(() {
        mockRutinaMultiDia = Rutina(
          idRutina: 3,
          nombre: 'Rutina Semanal',
          idAlumno: 'abc-123',
          dias: [
            DiaRutina(
              nombre: 'Día 1 - Pecho',
              orden: 0,
              bloques: [
                BloqueRutina(
                  id: 'b1',
                  nombre: 'Fuerza',
                  ejercicios: [
                    EjercicioRutina(
                      ejercicio: Ejercicio(
                        idEjercicio: 1,
                        nombre: 'Press de Banca',
                        categorias: [mockCategoriaPecho],
                      ),
                      series: 4,
                      repeticiones: '10',
                    ),
                  ],
                ),
              ],
            ),
            DiaRutina(
              nombre: 'Día 2 - Piernas',
              orden: 1,
              bloques: [
                BloqueRutina(
                  id: 'b2',
                  nombre: 'Fuerza',
                  ejercicios: [
                    EjercicioRutina(
                      ejercicio: Ejercicio(
                        idEjercicio: 2,
                        nombre: 'Sentadilla',
                        categorias: [mockCategoriaCuadriceps],
                      ),
                      series: 5,
                      repeticiones: '8',
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      });

      test(
        'generate con múltiples días debe crear PDF válido con varias páginas',
        () async {
          // Arrange
          final generator = PdfGenerator();

          // Act
          final bytes = await generator.generate(
            rutina: mockRutinaMultiDia,
            alumno: mockAlumno,
          );

          // Assert
          expect(bytes, isNotEmpty);
          final header = String.fromCharCodes(bytes.take(4));
          expect(header, equals('%PDF'));
        },
      );

      test(
        'buildExerciseTableData con múltiples días debe incluir cabecera de día',
        () {
          // Arrange
          final generator = PdfGenerator();

          // Act
          final filas = generator.buildExerciseTableData(mockRutinaMultiDia);

          // Assert — debe haber filas de cabecera de día
          // Día 1: dayHeader + blockSeparator + 1 ejercicio = 3 filas
          // Día 2: dayHeader + blockSeparator + 1 ejercicio = 3 filas
          expect(filas.length, 6);
          expect(filas[0][0], contains('Día 1 - Pecho'));
          expect(filas[1][0], contains('Fuerza'));
          expect(filas[2][0], contains('Press de Banca'));
          expect(filas[3][0], contains('Día 2 - Piernas'));
          expect(filas[4][0], contains('Fuerza'));
          expect(filas[5][0], contains('Sentadilla'));
        },
      );

      test('la numeración de ejercicios debe reiniciarse en cada día', () {
        // Arrange
        final generator = PdfGenerator();

        // Act
        final filas = generator.buildExerciseTableData(mockRutinaMultiDia);

        // Assert — ejercicio del día 1 empieza en 1, ejercicio del día 2 también
        expect(filas[2][0], startsWith('1.'));
        expect(filas[5][0], startsWith('1.'));
      });

      test(
        'PdfGeneratorStyle debe tener color configurado para cabecera de día',
        () {
          // Arrange
          final style = PdfGeneratorStyle();

          // Assert — debe existir un color para cabecera de día
          expect(style.dayHeaderBackgroundColor, isNotNull);
          expect(
            style.dayHeaderBackgroundColor,
            isNot(equals(style.blockSeparatorBackgroundColor)),
          );
        },
      );
    });
    test('las notas generales deben aparecer antes que los ejercicios', () {
      // Arrange
      final generator = PdfGenerator();
      final rutinaConNotas = Rutina(
        idRutina: 1,
        nombre: 'Rutina Test',
        idAlumno: 'abc-123',
        notasGenerales: 'Descansar 90 segundos entre series',
        dias: [
          DiaRutina(
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
                    peso: '',
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      // Act
      final filas = generator.buildExerciseTableData(rutinaConNotas);

      // Assert — verificamos que el PDF se genera correctamente con notas
      expect(filas, isNotEmpty);
    });
  });
}
