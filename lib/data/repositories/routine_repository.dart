import '../models/routine_model.dart';

abstract class RoutineRepository {
  Future<bool> saveRoutine(Rutina rutina);
}

class MockRoutineRepository implements RoutineRepository {
  @override
  Future<bool> saveRoutine(Rutina rutina) async {
	// 1. IMPRIMIMOS LO QUE LLEGA DESDE LA PANTALLA
    print('====================================');
    print('💾 SIMULANDO GUARDADO DE RUTINA 💾');
    print('Nombre: ${rutina.nombre}');
    print('Cantidad de ejercicios: ${rutina.ejercicios.length}');
    
    for (var i = 0; i < rutina.ejercicios.length; i++) {
      final ej = rutina.ejercicios[i];
      print('  [${i + 1}] ${ej.ejercicio.nombre} - ${ej.series} series x ${ej.repeticiones} reps');
    }
    print('====================================');
    // Simulamos el tiempo de inserción en Supabase
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Acá iría el insert real. Por ahora, asumimos éxito rotundo.
    return true;
  }
}
