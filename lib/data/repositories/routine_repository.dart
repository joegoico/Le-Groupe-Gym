import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/dia_rutina_model.dart';
import 'package:le_groupe_gym/data/models/routine_block_model.dart';
import 'package:le_groupe_gym/data/models/exercise_model.dart';
import 'package:le_groupe_gym/data/models/exercise_routine_model.dart';

abstract class RoutineRepository {
  Future<int> saveRoutine(Rutina rutina);
  Future<void> updatePdfUrl({required int idRutina, required String url});
  Future<List<({Rutina rutina, Alumno alumno})>> getRutinas(); // 👈
  Future<List<({Rutina rutina, Alumno alumno})>> getRutinasPorAlumno(
    String idAlumno,
  ); // 👈
  Future<void> updateRoutine(Rutina rutina);
  Future<void> deleteRoutine(int idRutina);
  Future<Rutina?> getRutinaCompleta(int idRutina);
  Future<List<Rutina>> getRutinasPredeterminadas();
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
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      await supabaseClient
          .from('Rutinas')
          .update({'url_pdf': url, 'user_id': userId})
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
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      // Paso 1 — insertar cabecera en Rutinas
      final rutinaResponse = await supabaseClient
          .from('Rutinas')
          .insert({...rutina.toMap(), 'user_id': userId})
          .select('id_rutina')
          .single();

      final idRutina = rutinaResponse['id_rutina'] as int;

      // Paso 2 — insertar días, bloques y ejercicios
      for (final dia in rutina.dias) {
        final diaResponse = await supabaseClient
            .from('Dias_Rutina')
            .insert(dia.toMap(idRutina: idRutina))
            .select('id_dia')
            .single();

        final idDia = diaResponse['id_dia'] as int;

        for (
          var bloqueIndex = 0;
          bloqueIndex < dia.bloques.length;
          bloqueIndex++
        ) {
          final bloque = dia.bloques[bloqueIndex];

          // 👇 Insertar bloque
          final bloqueResponse = await supabaseClient
              .from('Bloques_Rutina')
              .insert({
                'id_dia': idDia,
                'nombre': bloque.nombre,
                'orden': bloqueIndex,
              })
              .select('id_bloque')
              .single();

          final idBloque = bloqueResponse['id_bloque'] as int;

          // 👇 Insertar ejercicios del bloque
          final ejerciciosData = <Map<String, dynamic>>[];
          var orden = 0;

          for (final tarjeta in bloque.ejercicios) {
            for (final miembro in tarjeta.miembros) {
              ejerciciosData.add({
                'id_dia': idDia,
                'id_bloque': idBloque,
                'id_ejercicio': miembro.ejercicio.idEjercicio,
                'series': miembro.series,
                'repeticiones': miembro.repeticiones,
                'orden': orden++,
              });
            }
          }

          if (ejerciciosData.isNotEmpty) {
            await supabaseClient
                .from('Rutina_Ejercicios')
                .insert(ejerciciosData);
          }
        }
      }

      return idRutina;
    } on PostgrestException catch (e) {
      throw Exception('Error al guardar rutina: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al guardar: $e');
    }
  }

  // En mock_routine_repository.dart
  @override
  Future<List<({Rutina rutina, Alumno alumno})>> getRutinas() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      final response = await supabaseClient
          .from('Rutinas')
          .select('*, Alumno(*)')
          .eq('user_id', userId)
          .eq('es_predeterminada', false)
          .order('fecha_creacion', ascending: false)
          .limit(10);

      return (response as List<dynamic>).map((json) {
        final rutina = Rutina.fromMap(json as Map<String, dynamic>);
        final alumno = Alumno.fromMap(json['Alumno'] as Map<String, dynamic>);
        return (rutina: rutina, alumno: alumno);
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener rutinas: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> updateRoutine(Rutina rutina) async {
    try {
      final diasPayload = rutina.dias.map((dia) {
        return {
          'nombre_dia': dia.nombre,
          'orden': dia.orden,
          'bloques': dia.bloques.asMap().entries.map((entry) {
            var orden = 0;
            return {
              'nombre': entry.value.nombre,
              'orden': entry.key,
              'ejercicios': entry.value.ejercicios
                  .expand(
                    (tarjeta) => tarjeta.miembros.map(
                      (miembro) => {
                        'id_ejercicio': miembro.ejercicio.idEjercicio,
                        'series': miembro.series,
                        'repeticiones': miembro.repeticiones,
                        'orden': orden++,
                      },
                    ),
                  )
                  .toList(),
            };
          }).toList(),
        };
      }).toList();

      await supabaseClient.rpc(
        'update_rutina',
        params: {
          'p_id_rutina': rutina.idRutina,
          'p_nombre': rutina.nombre,
          'p_notas_generales': rutina.notasGenerales,
          'p_dias': diasPayload,
        },
      );
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar rutina: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar: $e');
    }
  }

  @override
  Future<void> deleteRoutine(int idRutina) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      await supabaseClient
          .from('Rutinas')
          .delete()
          .eq('id_rutina', idRutina)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar rutina: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al eliminar: $e');
    }
  }

  @override
  Future<Rutina?> getRutinaCompleta(int idRutina) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      final response = await supabaseClient
          .from('Rutinas')
          .select('''
            *,
            Dias_Rutina (
              *,
              Bloques_Rutina (
                *,
                Rutina_Ejercicios (
                  *,
                  Ejercicios (
                    *,
                    Rel_Ejercicio_Categoria (
                      Categorias_Ejercicio (*)
                    )
                  )
                )
              )
            )
          ''')
          .eq('id_rutina', idRutina)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      final dias = (response['Dias_Rutina'] as List<dynamic>).map((diaJson) {
        final bloques = (diaJson['Bloques_Rutina'] as List<dynamic>).map((
          bloqueJson,
        ) {
          final ejercicios = (bloqueJson['Rutina_Ejercicios'] as List<dynamic>)
              .map((ejJson) {
                final ejercicioJson =
                    ejJson['Ejercicios'] as Map<String, dynamic>;
                final ejercicio = Ejercicio.fromJson(ejercicioJson);
                return EjercicioRutina(
                  ejercicio: ejercicio,
                  series: ejJson['series'] as int,
                  repeticiones: ejJson['repeticiones'] as String,
                  peso: ejJson['peso'] as String? ?? '',
                );
              })
              .toList();

          return BloqueRutina(
            id: 'bloque-${bloqueJson['id_bloque']}',
            nombre: bloqueJson['nombre'] as String,
            ejercicios: ejercicios,
          );
        }).toList();

        return DiaRutina(
          idDia: diaJson['id_dia'] as int,
          nombre: diaJson['nombre_dia'] as String,
          orden: diaJson['orden'] as int,
          bloques: bloques,
        );
      }).toList()..sort((a, b) => a.orden.compareTo(b.orden));

      return Rutina.fromMap(response, dias: dias);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener rutina completa: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<List<({Rutina rutina, Alumno alumno})>> getRutinasPorAlumno(
    String idAlumno,
  ) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      final response = await supabaseClient
          .from('Rutinas')
          .select('*, Alumno(*)')
          .eq('id_alumno', idAlumno)
          .eq('user_id', userId)
          .order('fecha_creacion', ascending: false);

      return (response as List<dynamic>).map((json) {
        final rutina = Rutina.fromMap(json as Map<String, dynamic>);
        final alumno = Alumno.fromMap(json['Alumno'] as Map<String, dynamic>);
        return (rutina: rutina, alumno: alumno);
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener rutinas por alumno: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<List<Rutina>> getRutinasPredeterminadas() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;

      // Filtramos solo las rutinas predeterminadas
      final response = await supabaseClient
          .from('Rutinas')
          .select('*')
          .eq('es_predeterminada', true)
          .eq('user_id', userId)
          .order('fecha_creacion', ascending: false)
          .limit(50);

      return (response as List<dynamic>)
          .map((json) => Rutina.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener rutinas predeterminadas: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
