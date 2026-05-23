import 'package:flutter/material.dart';
import 'data/models/exercise_model.dart';
import 'presentacion/builder/widgets/exercise_sidebar.dart'; 

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
      // CONFIGURACIÓN DEL TEMA AL ESTILO VERCEL (v0)
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), // El negro profundo de Vercel
        fontFamily: 'Segoe UI',
        useMaterial3: true,
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
      home: MainPanelPage(),
    );
  }
}

class MainPanelPage extends StatelessWidget {
  MainPanelPage({super.key});

  // LISTA DE MOCKS ENRIQUECIDA: Conectamos los subgrupos relacionales
  final List<Ejercicio> mockExercises = [
    Ejercicio(
      idEjercicio: 1,
      nombre: 'Press de Banca Plano',
      categorias: [
        CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
        CategoriaEjercicio(idCategoria: 10, nombre: 'Pectoral Mayor', tipo: 'subgrupo'),
        CategoriaEjercicio(idCategoria: 2, nombre: 'Barra', tipo: 'modalidad'),
      ],
    ),
    Ejercicio(
      idEjercicio: 2,
      nombre: 'Cruces de Polea Alta',
      categorias: [
        CategoriaEjercicio(idCategoria: 1, nombre: 'Pecho', tipo: 'grupo_muscular'),
        CategoriaEjercicio(idCategoria: 12, nombre: 'Fibras Inferiores', tipo: 'subgrupo'),
      ],
    ),
    Ejercicio(
      idEjercicio: 3,
      nombre: 'Sentadilla Libre Back Squat',
      categorias: [
        CategoriaEjercicio(idCategoria: 5, nombre: 'Piernas', tipo: 'grupo_muscular'),
        CategoriaEjercicio(idCategoria: 11, nombre: 'Cuádriceps', tipo: 'subgrupo'),
        CategoriaEjercicio(idCategoria: 2, nombre: 'Barra', tipo: 'modalidad'),
      ],
    ),
    Ejercicio(
      idEjercicio: 4,
      nombre: 'Sillón de Cuádriceps',
      categorias: [
        CategoriaEjercicio(idCategoria: 5, nombre: 'Piernas', tipo: 'grupo_muscular'),
        CategoriaEjercicio(idCategoria: 11, nombre: 'Cuádriceps', tipo: 'subgrupo'),
      ],
    ),
    Ejercicio(
      idEjercicio: 5,
      nombre: 'Press Militar con Mancuerna',
      categorias: [
        CategoriaEjercicio(idCategoria: 6, nombre: 'Hombros', tipo: 'grupo_muscular'),
        CategoriaEjercicio(idCategoria: 13, nombre: 'Deltoides Anterior', tipo: 'subgrupo'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. BARRA LATERAL (Conectada al SidebarController y a los nuevos Mocks)
          ExcerciseSidebar(
            allExercises: mockExercises,
            onAddExercise: (ejercicio) {
              debugPrint('Agregando a la rutina: ${ejercicio.nombre}');
            },
          ),
          
          // 2. WORKSPACE PRINCIPAL (Estilo Canvas de Vercel)
          Expanded(
            child: Container(
              color: const Color(0xFF121212), // Contraste sutil con el sidebar
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dashboard_customize_outlined, 
                      color: Colors.grey, 
                      size: 48
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Zona de Armado de Rutinas', 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 16, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Arrastrá o seleccioná ejercicios del panel izquierdo', 
                      style: TextStyle(
                        color: Colors.grey, 
                        fontSize: 13
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}