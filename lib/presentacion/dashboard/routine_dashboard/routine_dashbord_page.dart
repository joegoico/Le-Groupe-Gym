import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:url_launcher/url_launcher.dart';

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
import 'package:le_groupe_gym/presentacion/builder/sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/logout_confirm_dialog.dart';

class RutinasDashboardPage extends ConsumerStatefulWidget {
  const RutinasDashboardPage({super.key});

  @override
  ConsumerState<RutinasDashboardPage> createState() =>
      _RutinasDashboardPageState();
}

class _RutinasDashboardPageState extends ConsumerState<RutinasDashboardPage> {
  bool _isLoading = true;
  bool _sidebarCollapsed = false;
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
      await Future.wait([_loadSolicitudes(), _loadRutinas()]);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSolicitudes() async {
    final repo = ref.read(solicitudRutinaRepositoryProvider);
    final solicitudes = await repo.getSolicitudes();
    if (mounted) setState(() => _solicitudes = solicitudes);
  }

  Alumno? _alumnoFiltro;

  Future<void> _loadRutinas() async {
    final repo = ref.read(routineRepositoryProvider);
    final rutinas = await repo.getRutinas();
    if (mounted) setState(() => _rutinas = rutinas);
  }

  Future<void> _filtrarPorAlumno(Alumno alumno) async {
    final repo = ref.read(routineRepositoryProvider);
    final rutinas = await repo.getRutinasPorAlumno(alumno.idAlumno);
    if (mounted) setState(() => _rutinas = rutinas);
  }

  void _eliminarSolicitudLocal(SolicitudRutina solicitud) {
    setState(() {
      _solicitudes.removeWhere((s) => s.idSolicitud == solicitud.idSolicitud);
    });
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
              pagoRepository: ref.read(pagoRepositoryProvider),
              deudorRepository: ref.read(deudorRepositoryProvider),
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
                  SnackBar(
                    content: Text(
                      'Solicitud de rutina creada exitosamente',
                      style: AppTextStyles.subtittlesBold.copyWith(
                        color: AppColors.successContent,
                      ),
                    ),
                    backgroundColor: AppColors.successContainer,
                    behavior: SnackBarBehavior.floating,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.md),
                    ),
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
      body: Row(
        children: [
          Sidebar(
            currentRoute: '/',
            isCollapsed: _sidebarCollapsed,
            onCerrarSesion: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => const LogoutConfirmDialog(),
              );
              if (confirm == true) {
                await SupabaseConfig.client.auth.signOut();
                if (mounted) context.go('/login');
              }
            },
            onNavigate: (route) => context.go(route),
          ),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  onMenuPressed: () =>
                      setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                  pageTitle: 'Rutinas',
                  actionsCenter: [
                    SizedBox(
                      width: 320,
                      child: AlumnoSelector(
                        alumnoRepository: ref.read(alumnoRepositoryProvider),
                        alumnoSeleccionado: _alumnoFiltro,
                        hintText: 'Filtrar rutinas por alumno...',
                        onAlumnoChanged: (alumno) {
                          setState(() => _alumnoFiltro = alumno);
                          if (alumno != null) {
                            _filtrarPorAlumno(alumno);
                          } else {
                            _loadRutinas();
                          }
                        },
                      ),
                    ),
                  ],
                  actionsEnd: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final nuevaRutina = await context
                            .push<({Rutina rutina, Alumno alumno})?>(
                              '/crear-rutina',
                            );
                        if (nuevaRutina != null) {
                          setState(() {
                            _rutinas.insert(0, nuevaRutina);
                            if (_rutinas.length > 10) {
                              _rutinas.removeLast();
                            }
                          });
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        'Crear Rutina',
                        style: AppTextStyles.buttonText,
                      ),
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
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 860),
                              child: Column(
                                children: [
                                  SolicitudesPanel(
                                    solicitudes: _solicitudes,
                                    onRegistrarSolicitud:
                                        _showRegistrarSolicitudForm,
                                    onResolverSolicitud: (solicitud) async {
                                      final resultado = await context.push(
                                        '/crear-rutina',
                                        extra: solicitud,
                                      );
                                      _loadRutinas();
                                      if (resultado != null) {
                                        _eliminarSolicitudLocal(solicitud);
                                      }
                                    },
                                    onEliminarSolicitud: (solicitud) async {
                                      final solicitudRepo = ref.read(
                                        solicitudRutinaRepositoryProvider,
                                      );
                                      await solicitudRepo.deleteSolicitud(
                                        solicitud.idSolicitud!,
                                      );
                                      _eliminarSolicitudLocal(solicitud);
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  RutinasPanel(
                                    rutinas: _rutinas,
                                    onVerDetalle: (rutina) async {
                                      if (rutina.urlPdf != null) {
                                        final uri = Uri.parse(rutina.urlPdf!);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(
                                            uri,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                      }
                                    },
                                    onEditarRutina: (rutina) async {
                                      debugPrint(
                                        'Editar rutina: ${rutina.idRutina}',
                                      );
                                      debugPrint('dias: ${rutina.dias}');
                                      final rutinaActualizada = await context
                                          .push<
                                            ({Rutina rutina, Alumno alumno})?
                                          >('/editar-rutina', extra: rutina);
                                      if (rutinaActualizada != null) {
                                        setState(() {
                                          final index = _rutinas.indexWhere(
                                            (r) =>
                                                r.rutina.idRutina ==
                                                rutinaActualizada
                                                    .rutina
                                                    .idRutina,
                                          );
                                          if (index != -1) {
                                            _rutinas[index] = rutinaActualizada;
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
