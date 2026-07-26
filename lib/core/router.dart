import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/presentacion/auth/login_page.dart';
import 'package:le_groupe_gym/presentacion/pages/routine_work_page.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_dashbord_page.dart';
import 'package:le_groupe_gym/presentacion/pages/precios_page.dart';
import 'package:le_groupe_gym/presentacion/pages/alumnos_page.dart';
import 'package:le_groupe_gym/presentacion/pages/alumno_detalle_page.dart';
import 'package:le_groupe_gym/presentacion/pages/alumno_pagos_page.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = SupabaseConfig.client.auth.currentSession;
    final isLoggedIn = session != null;
    final isLoginPage = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginPage) return '/login';
    if (isLoggedIn && isLoginPage) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(onLogin: () => context.go('/')),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const RutinasDashboardPage(),
    ),
    GoRoute(path: '/alumnos', builder: (context, state) => const AlumnosPage()),
    GoRoute(
      path: '/alumnos/detalle',
      builder: (context, state) {
        final alumno = state.extra as Alumno;
        return AlumnoDetallePage(alumno: alumno);
      },
    ),
    GoRoute(
      path: '/alumnos/pagos',
      builder: (context, state) {
        final alumno = state.extra as Alumno;
        return AlumnoPagosPage(alumno: alumno);
      },
    ),
    GoRoute(path: '/precios', builder: (context, state) => const PreciosPage()),
    GoRoute(
      path: '/crear-rutina',
      builder: (context, state) {
        final solicitud = state.extra as SolicitudRutina?;
        return MainPanelPage(solicitudOrigen: solicitud);
      },
    ),
    GoRoute(
      path: '/editar-rutina',
      builder: (context, state) {
        final rutina = state.extra as Rutina;
        return MainPanelPage(rutinaExistente: rutina);
      },
    ),
  ],
);
