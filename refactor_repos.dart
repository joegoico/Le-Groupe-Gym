import 'dart:io';

void main() {
  final directory = Directory('lib/data/repositories');
  final files = directory.listSync().whereType<File>().where((f) => f.path.endsWith('.dart'));

  final targetString = 'final userId = SupabaseConfig.client.auth.currentUser!.id;';
  final replacement = '''final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa.');
      final userId = user.id;''';

  for (final file in files) {
    var content = file.readAsStringSync();
    if (content.contains(targetString)) {
      content = content.replaceAll(targetString, replacement);
      file.writeAsStringSync(content);
      print('Updated \${file.path}');
    }
  }
}
