import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/core/router.dart';

void main() {
  test('El appRouter debe estar inicializado correctamente', () {
    // Verificamos que appRouter es válido. La lógica de refreshListenable
    // es interna de GoRouter y fue configurada en router.dart.
    expect(appRouter, isA<GoRouter>());
    expect(appRouter.routerDelegate, isNotNull);
  });
}
