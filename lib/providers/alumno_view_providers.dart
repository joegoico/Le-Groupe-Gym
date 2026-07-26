import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';

final rutinasAlumnoProvider =
    FutureProvider.family<List<({Rutina rutina, Alumno alumno})>, String>((
      ref,
      idAlumno,
    ) async {
      final repository = ref.watch(routineRepositoryProvider);
      return repository.getRutinasPorAlumno(idAlumno);
    });

final ultimoPagoAlumnoProvider = FutureProvider.family<Pago?, String>((
  ref,
  idAlumno,
) async {
  final repository = ref.watch(pagoRepositoryProvider);
  return repository.getUltimoPago(idAlumno);
});

final pagosAlumnoAnoProvider = FutureProvider.family<List<Pago>, String>((
  ref,
  idAlumno,
) async {
  final repository = ref.watch(pagoRepositoryProvider);
  final currentYear = DateTime.now().year;
  return repository.getPagosPorAlumno(idAlumno, anio: currentYear);
});
