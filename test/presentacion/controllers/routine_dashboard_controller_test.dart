import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/presentacion/controllers/routine_dashboard_controller.dart';

void main() {
  group('RoutineDashboardController', () {
    Rutina _makeRutina(int id, String nombre) => Rutina(
          idRutina: id,
          nombre: nombre,
        );

    test('routines expone la lista completa pasada en el constructor', () {
      final rutinas = [
        _makeRutina(1, 'Rutina A'),
        _makeRutina(2, 'Rutina B'),
      ];

      final controller = RoutineDashboardController(routines: rutinas);

      expect(controller.routines.length, 2);
      expect(controller.routines[0].nombre, 'Rutina A');
      expect(controller.routines[1].nombre, 'Rutina B');
    });

    test('routines devuelve una copia inmutable de la lista interna', () {
      final rutinas = [_makeRutina(1, 'Rutina A')];
      final controller = RoutineDashboardController(routines: rutinas);

      // Modificar la lista devuelta no debe afectar al controller
      controller.routines.add(_makeRutina(2, 'Rutina B'));

      expect(controller.routines.length, 1);
    });

    test('acepta una lista vacía de rutinas', () {
      final controller = RoutineDashboardController(routines: []);

      expect(controller.routines, isEmpty);
    });
  });
}
