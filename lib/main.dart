import 'package:flutter/material.dart';
import 'presentacion/pages/main_panel_page.dart'; // Importamos la página que separamos

void main() {
  runApp(const MyApp());
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