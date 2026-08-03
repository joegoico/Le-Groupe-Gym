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
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
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
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
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
                        'observaciones': miembro.peso,
                        'orden': orden++,
                      },
                    ),
                  )
                  .toList(),
            };
          }).toList(),
        };
      }).toList();

      final response = await supabaseClient.rpc(
        'insert_rutina_completa',
        params: {
          'p_nombre': rutina.nombre,
          'p_id_alumno': rutina.idAlumno,
          'p_notas_generales': rutina.notasGenerales,
          'p_es_predeterminada': rutina.esPredeterminada,
          'p_dias': diasPayload,
        },
      );

      return response as int;
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
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
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
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
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
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
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
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;
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
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;

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
