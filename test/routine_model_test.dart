import 'package:flutter_test/flutter_test.dart';
// Importaremos el modelo real de rutina cuando lo creemos en el paso siguiente:
import 'package:le_groupe_gym/data/models/routine_model.dart';

void main() {
  group('Rutina Model Tests', () {
    test('Debe parsear un JSON de rutina con sus ejercicios cargados y mantener el orden', () {
      // 1. ARRANGEMENT
      final Map<String, dynamic> routineJsonMock = {
        'id_rutina': 101,
        'nombre_rutina': 'Fuerza - Mes 1',
        'alumno_id': 'alumno-uuid-123',
        'fecha_creacion': '2026-05-22T10:00:00Z',
        'Rutina_Ejercicios': [
          {
            'id_rutina_ejercicio': 501,
            'orden': 1,
            'series': 4,
            'repeticiones': '8-10',
            'descanso_segundos': 90,
            'notas': 'Controlar la fase excéntrica',
            'Ejercicios': {
              'id_ejercicio': 42,
              'nombre': 'Sentadilla profunda con barra'
            }
          }
        ]
      };

      // 2. ACT
      final rutina = Rutina.fromJson(routineJsonMock);

      // 3. ASSERT
      expect(rutina.idRutina, 101);
      expect(rutina.nombreRutina, 'Fuerza - Mes 1');
      expect(rutina.alumnoId, 'alumno-uuid-123');
      expect(rutina.fechaCreacion, DateTime.parse('2026-05-22T10:00:00Z'));
      
      // Validamos la lista interna de ejercicios asignados a la rutina
      expect(rutina.ejerciciosAsignados.length, 1);
      
      final ejercicioAsignado = rutina.ejerciciosAsignados.first;
      expect(ejercicioAsignado.idRutinaEjercicio, 501);
      expect(ejercicioAsignado.orden, 1);
      expect(ejercicioAsignado.series, 4);
      expect(ejercicioAsignado.repeticiones, '8-10');
      expect(ejercicioAsignado.descansoSegundos, 90);
      expect(ejercicioAsignado.notas, 'Controlar la fase excéntrica');
      
      // Validamos que arrastre los datos base del ejercicio interno
      expect(ejercicioAsignado.nombreEjercicio, 'Sentadilla profunda con barra');
      expect(ejercicioAsignado.idEjercicio, 42);
    });
  });
}