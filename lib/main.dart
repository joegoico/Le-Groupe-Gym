import 'package:flutter/material.dart';
// Asumiendo que creás el archivo de la barra lateral en la misma carpeta
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
      theme: ThemeData.dark(), // Usamos tema oscuro para que pegue con el diseño de v0
      home: const Scaffold(
        body: Row(
          children: [
            // Ponemos tu barra lateral a la izquierda de la pantalla
            ExcerciseSidebar(
              searchQuery: '',
              onSearchChange: _dummyStringCallback,
              selectedMuscleGroup: {},
              onMuscleGroupsChange: _dummySetCallback,
              selectedSubgroups: {},
              onSubgroupsChange: _dummySetCallback,
              selectedModalities: {},
              onModalitiesChange: _dummySetCallback,
              addedExerciseIds: [],
              onAddExercise: _dummyStringCallback,
              allExercises: [], // Arranca vacío hasta que conectemos Supabase
            ),
            // El resto de la pantalla (el Workspace) por ahora vacío
            Expanded(
              child: Center(
                child: Text('Acá va a ir el Workspace de la rutina', 
                  style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Funciones auxiliares mudas solo para que compile el Stateless inicial
void _dummyStringCallback(String val) {}
void _dummySetCallback(Set<String> val) {}