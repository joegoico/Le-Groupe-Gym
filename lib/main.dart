import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // falta esto
import 'presentacion/pages/main_panel_page.dart'; // Importamos la página que separamos
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importamos dotenv para cargar variables de entorno


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Le Groupe Gym - Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        fontFamily: 'Segoe UI',
        useMaterial3: true,
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
      // Apuntamos a la pantalla que ahora vive en su propio archivo
      home: const MainPanelPage(), 
    );
  }
}