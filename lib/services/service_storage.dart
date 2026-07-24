import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient? supabaseClient;
  static const String _bucket = 'rutinas-pdf';

  StorageService({this.supabaseClient});

  // Genera un path único y predecible para el PDF
  String buildFilePath({required int idRutina, required String idAlumno}) {
    return 'alumnos/$idAlumno/rutina_$idRutina.pdf';
  }

  // Sube el PDF a Supabase Storage y retorna la URL pública
  Future<String> uploadPdf({
    required Uint8List bytes,
    required int idRutina,
    required String idAlumno,
  }) async {
    final client = supabaseClient ?? Supabase.instance.client;
    final path = buildFilePath(idRutina: idRutina, idAlumno: idAlumno);

    await client.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: true, // sobreescribe si ya existe
          ),
        );

    return client.storage.from(_bucket).getPublicUrl(path);
  }

  Future<void> deletePdf({
    required int idRutina,
    required String idAlumno,
  }) async {
    try {
      await Supabase.instance.client.storage.from('rutinas-pdf').remove([
        'alumnos/$idAlumno/rutina_$idRutina.pdf',
      ]);
    } catch (e) {
      debugPrint('Error al eliminar PDF: $e');
    }
  }
}
