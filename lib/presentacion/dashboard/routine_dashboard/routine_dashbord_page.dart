import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_widgets/rutinas_panel.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_widgets/solicitudes_panel.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/top_bar.dart';
import 'package:le_groupe_gym/presentacion/forms/solicitud_rutina_form.dart';
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
  final List<SolicitudRutina> _recentlyCreatedSolicitudes = [];
  List<({Rutina rutina, Alumno alumno})> _rutinas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final solicitudRepo = ref.read(solicitudRutinaRepositoryProvider);

      final solicitudes = await solicitudRepo.getSolicitudes();
      print('Solicitudes cargadas: ${solicitudes.length}');
      final mergedSolicitudes = _mergeWithRecentlyCreated(solicitudes);
      // Por ahora retornamos lista vacía de rutinas hasta implementar getRutinas

      if (mounted) {
        setState(() {
          _solicitudes = mergedSolicitudes;
          _rutinas = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<SolicitudRutina> _mergeWithRecentlyCreated(
    List<SolicitudRutina> solicitudes,
  ) {
    final ids = solicitudes.map((s) => s.idSolicitud).whereType<int>().toSet();

    _recentlyCreatedSolicitudes.removeWhere(
      (s) => s.idSolicitud != null && ids.contains(s.idSolicitud),
    );

    return [..._recentlyCreatedSolicitudes, ...solicitudes];
  }

  Future<void> _showRegistrarSolicitudForm() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AddSolicitudRutinaForm(
              alumnoRepository: ref.read(alumnoRepositoryProvider),
              solicitudRutinaRepository: ref.read(
                solicitudRutinaRepositoryProvider,
              ),
              onCancelar: () => Navigator.of(dialogContext).pop(),
              onGuardar: (solicitud) {
                if (mounted) {
                  setState(() {
                    _recentlyCreatedSolicitudes.insert(0, solicitud);
                    _solicitudes = [solicitud, ..._solicitudes];
                  });
                }
                Navigator.of(dialogContext).pop();
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Solicitud de rutina creada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
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
                  context.push('/crear-rutina');
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
                          onRegistrarSolicitud: _showRegistrarSolicitudForm,
                          onResolverSolicitud: (solicitud) =>
                              context.push('/crear-rutina', extra: solicitud),
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
