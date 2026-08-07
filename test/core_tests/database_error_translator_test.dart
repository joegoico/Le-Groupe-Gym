import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/core/database_error_translator.dart';
import 'package:le_groupe_gym/core/app_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('DatabaseErrorTranslator', () {
    test('traduce el pago duplicado mensual', () {
      final error = PostgrestException(
        message: 'duplicate key value violates unique constraint',
        code: '23505',
        details: 'Key already exists',
        hint: 'idx_pago_unico_por_mes',
      );
      final result = DatabaseErrorTranslator.translate(error);
      expect(result, isA<DuplicateFailure>());
      expect(result.message, 'El alumno ya tiene un pago registrado para ese mes.');
    });

    test('traduce restricciones de importe y permisos', () {
      final importeResult = DatabaseErrorTranslator.translate(
        PostgrestException(
          message: 'check',
          code: '23514',
          hint: 'check_pago_monto',
        ),
      );
      expect(importeResult, isA<ValidationFailure>());
      expect(importeResult.message, 'El importe debe ser mayor a cero.');

      final permissionResult = DatabaseErrorTranslator.translate(
        PostgrestException(message: 'denied', code: '42501'),
      );
      expect(permissionResult, isA<PermissionFailure>());
      expect(permissionResult.message, 'No tenés permiso para realizar esta acción.');
    });

    test('no expone detalles técnicos en casos desconocidos', () {
      final result = DatabaseErrorTranslator.translate(
        Exception('relation secret_table does not exist'),
      );
      expect(result, isA<NetworkFailure>());
      expect(result.message, 'No se pudo completar la operación. Intentá nuevamente.');
    });
  });
}
