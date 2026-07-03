import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_dashbord_page.dart';
import 'package:le_groupe_gym/presentacion/pages/routine_work_page.dart';

/// Centraliza todas las rutas nombradas de la aplicación.
///
/// Uso en [MaterialApp]:
/// ```dart
/// MaterialApp.router(
///   routerConfig: router,
/// )
/// ```
///
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RutinasDashboardPage(),
    ),
    GoRoute(
      path: '/crear-rutina',
      builder: (context, state) => const MainPanelPage(),
    ),
  ],
);
