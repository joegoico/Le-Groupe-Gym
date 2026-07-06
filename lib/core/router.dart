import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/presentacion/pages/routine_work_page.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_dashbord_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RutinasDashboardPage(),
    ),
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
