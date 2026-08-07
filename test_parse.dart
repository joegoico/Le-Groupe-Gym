import 'dart:io';

import 'package:le_groupe_gym/data/models/deudor_model.dart';

void main() {
  final map = {
    'id_deudor': 'abc',
    'nombre': 'Test',
    'apellido': 'Test',
    'dias_adeudados': 1,
    'created_at': '2026-08-04T21:18:00+00:00',
  };
  try {
    Deudor.fromMap(map);
  } catch (_) {
    exitCode = 1;
  }
}
