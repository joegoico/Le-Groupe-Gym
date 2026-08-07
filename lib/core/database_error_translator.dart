import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_groupe_gym/core/app_failure.dart';

/// Convierte fallos técnicos de Supabase/Postgres en fallos tipados [AppFailure].
class DatabaseErrorTranslator {
  const DatabaseErrorTranslator._();

  static AppFailure translate(Object error) {
    if (error.toString().contains('No hay sesión activa.')) {
      return const SessionFailure('No hay sesión activa.');
    }
    if (error is PostgrestException) {
      final source = '${error.message} ${error.details ?? ''} ${error.hint ?? ''}'.toLowerCase();
      if (error.code == '23505') {
        if (source.contains('idx_pago_unico_por_mes')) return const DuplicateFailure('El alumno ya tiene un pago registrado para ese mes.');
        if (source.contains('idx_alumno_unico_nombre_apellido')) return const DuplicateFailure('Ya existe un alumno con ese nombre y apellido.');
        if (source.contains('unique_nombre_rutina_predeterminada')) return const DuplicateFailure('Ya existe una rutina genérica con este nombre.');
        return const DuplicateFailure('Ya existe un registro con esos datos.');
      }
      if (error.code == '23503') return const RelationFailure('No podés realizar esta acción porque hay información relacionada.');
      if (error.code == '42501') return const PermissionFailure('No tenés permiso para realizar esta acción.');
      if (error.code == '23502') return const ValidationFailure('Falta completar un dato obligatorio.');
      if (error.code == '23514') {
        if (source.contains('monto') || source.contains('valor')) return const ValidationFailure('El importe debe ser mayor a cero.');
        if (source.contains('dias')) return const ValidationFailure('La cantidad de días debe estar entre 1 y 7.');
        return const ValidationFailure('Uno de los datos ingresados no es válido.');
      }
      if (error.code == 'PGRST116') return const NotFoundFailure('El registro no existe o ya fue eliminado.');
    }
    return const NetworkFailure('No se pudo completar la operación. Intentá nuevamente.');
  }
}
