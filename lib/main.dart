import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // falta esto
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importamos dotenv para cargar variables de entorno
import 'package:le_groupe_gym/core/router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:le_groupe_gym/core/global_messenger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  await dotenv.load(fileName: '.env');
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Le Groupe Gym - Panel',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
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
      routerConfig: appRouter,
    );
  }
}
