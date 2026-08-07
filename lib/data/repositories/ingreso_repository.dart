import 'package:le_groupe_gym/core/app_failure.dart';
import 'package:le_groupe_gym/core/database_error_translator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/data/models/ingreso_model.dart';
import 'package:le_groupe_gym/data/models/resumen_mensual_model.dart';

abstract class IngresoRepository {
  /// Devuelve todos los ingresos individuales (para pantalla de detalle).
  Future<List<Ingreso>> getIngresos();

  /// Devuelve resúmenes mensuales agregados via RPC (para pantalla principal).
  Future<List<ResumenMensual>> getResumenesMensuales({
    DateTime? desde,
    DateTime? hasta,
    DateTime? fecha,
  });

  Future<String> createIngreso(Ingreso ingreso);

  Future<List<Ingreso>> getIngresosPorPeriodo({
    required DateTime desde,
    required DateTime hasta,
  });

  Future<List<Ingreso>> getIngresosPorFecha({required DateTime fecha});
}

class SupabaseIngresoRepository implements IngresoRepository {
  final SupabaseClient supabaseClient;

  SupabaseIngresoRepository({required this.supabaseClient});

  @override
  Future<List<Ingreso>> getIngresos() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw const SessionFailure('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Ingresos')
          .select()
          .eq('user_id', userId)
          .order('fecha_ingreso', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Ingreso.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    } catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    }
  }

  @override
  Future<List<ResumenMensual>> getResumenesMensuales({
    DateTime? desde,
    DateTime? hasta,
    DateTime? fecha,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (fecha != null) {
        params['p_fecha'] = fecha.toIso8601String().split('T')[0];
      } else {
        if (desde != null) {
          params['p_desde'] = desde.toIso8601String().split('T')[0];
        }
        if (hasta != null) {
          params['p_hasta'] = hasta.toIso8601String().split('T')[0];
        }
      }

      final response = await supabaseClient.rpc(
        'get_resumenes_mensuales',
        params: params,
      );

      return (response as List<dynamic>)
          .map((json) => ResumenMensual.fromRpc(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    } catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    }
  }

  @override
  Future<String> createIngreso(Ingreso ingreso) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw const SessionFailure('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Ingresos')
          .insert({...ingreso.toMap(), 'user_id': userId})
          .select('id_ingreso')
          .single();

      return response['id_ingreso'] as String;
    } on PostgrestException catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    } catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    }
  }

  @override
  Future<List<Ingreso>> getIngresosPorPeriodo({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw const SessionFailure('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Ingresos')
          .select()
          .eq('user_id', userId)
          .gte('fecha_ingreso', desde.toIso8601String().split('T')[0])
          .lte('fecha_ingreso', hasta.toIso8601String().split('T')[0])
          .order('fecha_ingreso', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Ingreso.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    } catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    }
  }

  @override
  Future<List<Ingreso>> getIngresosPorFecha({required DateTime fecha}) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw const SessionFailure('No hay sesión activa.');
      final userId = user.id;
      final response = await supabaseClient
          .from('Ingresos')
          .select()
          .eq('user_id', userId)
          .eq('fecha_ingreso', fecha.toIso8601String().split('T')[0])
          .order('fecha_ingreso', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Ingreso.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    } catch (e) {
      throw DatabaseErrorTranslator.translate(e);
    }
  }
}
