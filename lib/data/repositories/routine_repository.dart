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
  Future<void> updatePdfUrl({required int idRutina, required String url}) async {
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
      // Paso 1: insertar cabecera en Rutinas y recuperar el id generado
      final rutinaResponse = await supabaseClient
          .from('Rutinas')
          .insert(rutina.toMap())
          .select('id_rutina')
          .single();

      final idRutina = rutinaResponse['id_rutina'] as int;

      // Paso 2: insertar cada miembro (superserie = 2 filas con el mismo id_combo)
      final ejerciciosData = rutina.buildEjerciciosInsertPayload(idRutina);

      if (ejerciciosData.isNotEmpty) {
        await supabaseClient.from('Rutina_Ejercicios').insert(ejerciciosData);
      }

      return idRutina;
    } on PostgrestException catch (e) {
      throw Exception('Error al guardar rutina: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al guardar: $e');
    }
  }
}