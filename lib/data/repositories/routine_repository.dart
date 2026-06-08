import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';

abstract class RoutineRepository {
  Future<int> saveRoutine(Rutina rutina);
  Future<void> updatePdfUrl({required int idRutina, required String url});
}

class SupabaseRoutineRepository implements RoutineRepository {
  final SupabaseClient supabaseClient;

  SupabaseRoutineRepository({required this.supabaseClient});

  @override
  Future<void> updatePdfUrl({
    required int idRutina,
    required String url,
  }) async {
    try {
      await supabaseClient
          .from('Rutinas')
          .update({'url_pdf': url})
          .eq('id_rutina', idRutina);
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar url_pdf: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar url_pdf: $e');
    }
  }

  @override
  Future<int> saveRoutine(Rutina rutina) async {
    try {
      // Paso 1 — insertar cabecera en Rutinas
      final rutinaResponse = await supabaseClient
          .from('Rutinas')
          .insert(rutina.toMap())
          .select('id_rutina')
          .single();

      final idRutina = rutinaResponse['id_rutina'] as int;

      // Paso 2 — insertar cada día y sus ejercicios
      for (var diaIndex = 0; diaIndex < rutina.dias.length; diaIndex++) {
        final dia = rutina.dias[diaIndex];

        // Insertar el día
        final diaResponse = await supabaseClient
            .from('Dias_Rutina')
            .insert(dia.toMap(idRutina: idRutina))
            .select('id_dia')
            .single();

        final idDia = diaResponse['id_dia'] as int;

        // Insertar ejercicios del día
        final ejerciciosData = <Map<String, dynamic>>[];
        var orden = 0;

        for (final bloque in dia.bloques) {
          for (final tarjeta in bloque.ejercicios) {
            for (
              var slotIndex = 0;
              slotIndex < tarjeta.miembros.length;
              slotIndex++
            ) {
              final miembro = tarjeta.miembros[slotIndex];
              ejerciciosData.add({
                'id_dia': idDia,
                'id_ejercicio': miembro.ejercicio.idEjercicio,
                'series': miembro.series,
                'repeticiones': miembro.repeticiones,
                'orden': orden,
              });
              orden++;
            }
          }
        }

        if (ejerciciosData.isNotEmpty) {
          await supabaseClient.from('Rutina_Ejercicios').insert(ejerciciosData);
        }
      }

      return idRutina;
    } on PostgrestException catch (e) {
      throw Exception('Error al guardar rutina: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al guardar: $e');
    }
  }
}
