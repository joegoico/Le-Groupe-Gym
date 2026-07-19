import 'package:flutter/foundation.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';

class RoutineDashboardController extends ChangeNotifier {
  final List<Rutina> _routines;

  RoutineDashboardController({required List<Rutina> routines})
    : _routines = routines;

  List<Rutina> get routines => List.from(_routines);
}
