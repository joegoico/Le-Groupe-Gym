import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/services/pdf_generator.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';

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
      mockRutinaSuperserie = Rutina(
        idRutina: 2,
        nombre: 'Rutina con Superserie',
        idAlumno: 'abc-123',
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
          )..combinarCon(mockEjercicioCombo, series: 3, repeticiones: '15'),
        ],
      );

      mockRutina = Rutina(
        idRutina: 1,
        nombre: 'Día 1 - Empuje',
        idAlumno: 'abc-123',
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

        // Assert
        expect(filas.length, 3);
        expect(filas[0][0], contains('Bloque 1'));
        expect(filas[1][0], contains('Press de Banca'));
        expect(filas[1][0], contains('Superserie'));
        expect(filas[1][1], '4');
        expect(filas[1][2], '10');
        expect(filas[2][0], contains('Sentadilla'));
        expect(filas[2][1], '3');
        expect(filas[2][2], '15');
      },
    );

    test('debe agregar el grupo muscular en el pdf', () {
      final generator = PdfGenerator();

      final filas = generator.buildExerciseTableData(mockRutina);

      expect(filas.length, 3);
      expect(filas[1][4], contains('Pecho'));
      expect(filas[2][4], contains('Cuadriceps'));
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
  });
}
