import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:le_groupe_gym/core/env.dart';

class EmailService {

  Map<String, dynamic> buildPayload({
    required String pdfUrl,
    required String mailAlumno,
    required String nombreAlumno,
    required String nombreRutina,
  }) {
    if (mailAlumno.isEmpty) {
      throw ArgumentError('mailAlumno no puede estar vacío');
    }
    return {
      'pdfUrl': pdfUrl,
      'mailAlumno': mailAlumno,
      'nombreAlumno': nombreAlumno,
      'nombreRutina': nombreRutina,
    };
  }

  Future<void> enviarRutina({
    required String pdfUrl,
    required String mailAlumno,
    required String nombreAlumno,
    required String nombreRutina,
  }) async {
    final payload = buildPayload(
      pdfUrl: pdfUrl,
      mailAlumno: mailAlumno,
      nombreAlumno: nombreAlumno,
      nombreRutina: nombreRutina,
    );

    final response = await http.post(
      Uri.parse('${Env.supabaseUrl}/functions/v1/enviar-rutina'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Env.supabaseAnonKey}',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar mail: ${response.body} con ${response.statusCode}');
    }
  }
}