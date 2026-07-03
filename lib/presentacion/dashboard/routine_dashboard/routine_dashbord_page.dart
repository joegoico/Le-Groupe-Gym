import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/core/router.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/data/repositories/solicitud_rutina_repository.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_widgets/rutinas_panel.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_widgets/solicitudes_panel.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/top_bar.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';

class RutinasDashboardPage extends ConsumerStatefulWidget {
  const RutinasDashboardPage({super.key});

  @override
  ConsumerState<RutinasDashboardPage> createState() =>
      _RutinasDashboardPageState();
}

class _RutinasDashboardPageState extends ConsumerState<RutinasDashboardPage> {
  bool _isLoading = true;
  List<SolicitudRutina> _solicitudes = [];
  List<({Rutina rutina, Alumno alumno})> _rutinas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final solicitudRepo = ref.read(solicitudRutinaRepositoryProvider);
      final rutinaRepo = ref.read(routineRepositoryProvider);
      final alumnoRepo = ref.read(alumnoRepositoryProvider);

      final solicitudes = await solicitudRepo.getSolicitudes();
      // Por ahora retornamos lista vacía de rutinas hasta implementar getRutinas

      if (mounted) {
        setState(() {
          _solicitudes = solicitudes;
          _rutinas = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          TopBar(
            onMenuPressed: () {},
            pageTitle: 'Rutinas',
            actionsCenter: [
              SizedBox(
                width: 320,
                child: AlumnoSelector(
                  alumnoRepository: ref.read(alumnoRepositoryProvider),
                  alumnoSeleccionado: null,
                  onAlumnoChanged: (alumno) {},
                ),
              ),
            ],
            actionsEnd: [
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/crear-rutina');
                },
                icon: const Icon(Icons.add, size: 16),
                label: Text('Crear Rutina', style: AppTextStyles.buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppRadius.md),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        SolicitudesPanel(
                          solicitudes: _solicitudes,
                          onRegistrarSolicitud: () {},
                          onResolverSolicitud: (_) {},
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        RutinasPanel(rutinas: _rutinas, onVerDetalle: (_) {}),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
