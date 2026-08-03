import 'package:le_groupe_gym/services/pdf_generator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/core/global_messenger.dart';
import 'package:le_groupe_gym/services/auth_service.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/solicitud_rutina_model.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_widgets/rutinas_panel.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_widgets/rutinas_predeterminadas_panel.dart';
import 'package:le_groupe_gym/presentacion/dashboard/routine_dashboard/routine_widgets/solicitudes_panel.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/top_bar.dart';
import 'package:le_groupe_gym/presentacion/forms/solicitud_rutina_form.dart';
import 'package:le_groupe_gym/presentacion/forms/asignar_rutina_form.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:le_groupe_gym/presentacion/builder/sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/logout_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/delete_confirm_dialog.dart';
import 'package:le_groupe_gym/services/service_storage.dart';
import 'package:le_groupe_gym/services/email_service.dart';

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
  List<SolicitudRutina> _recentlyCreatedSolicitudes = [];
  List<({Rutina rutina, Alumno alumno})> _rutinas = [];
  List<Rutina> _rutinasPredeterminadas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _loadSolicitudes(),
        _loadRutinas(),
        _loadRutinasPredeterminadas(),
      ]);
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

  Future<void> _loadRutinasPredeterminadas() async {
    final repo = ref.read(routineRepositoryProvider);
    final rutinas = await repo.getRutinasPredeterminadas();
    if (mounted) setState(() => _rutinasPredeterminadas = rutinas);
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
                Navigator.of(dialogContext).pop();
                _onSolicitudGuardada(solicitud);
              },
            ),
          ),
        );
      },
    );
  }

  void _onSolicitudGuardada(SolicitudRutina solicitud) {
    final previousSolicitudes = List<SolicitudRutina>.from(_solicitudes);
    final previousRecent = List<SolicitudRutina>.from(_recentlyCreatedSolicitudes);

    setState(() {
      _solicitudes.insert(0, solicitud);
      _recentlyCreatedSolicitudes.insert(0, solicitud);
    });

    _guardarSolicitudEnBackground(solicitud, previousSolicitudes, previousRecent);
  }

  Future<void> _guardarSolicitudEnBackground(SolicitudRutina solicitud, List<SolicitudRutina> previousSolicitudes, List<SolicitudRutina> previousRecent) async {
    try {
      final idSolicitud = await ref.read(solicitudRutinaRepositoryProvider).createSolicitud(solicitud);
      
      if (mounted) {
        setState(() {
          final idx = _solicitudes.indexOf(solicitud);
          if (idx != -1) _solicitudes[idx] = solicitud.copyWith(idSolicitud: idSolicitud);
          
          final idx2 = _recentlyCreatedSolicitudes.indexOf(solicitud);
          if (idx2 != -1) _recentlyCreatedSolicitudes[idx2] = solicitud.copyWith(idSolicitud: idSolicitud);
        });
      }
      
      GlobalMessenger.showSuccessSnackbar('Solicitud de rutina creada exitosamente');
    } catch (e) {
      if (mounted) {
        setState(() {
          _solicitudes = previousSolicitudes;
          _recentlyCreatedSolicitudes = previousRecent;
        });
      }
      GlobalMessenger.showErrorSnackbar('Ocurrió un error inesperado al crear la solicitud de rutina. Verifica tu conexión e intenta de nuevo.');
    }
  }

  void _addGenericRoutine(Rutina r, Alumno alumno) {
    final rutinaClonada = Rutina(
      idRutina: -DateTime.now().millisecondsSinceEpoch,
      idAlumno: alumno.idAlumno,
      nombre: r.nombre,
      dias: [], 
      fechaCreacion: DateTime.now(),
      notasGenerales: r.notasGenerales,
      urlPdf: null,
      esPredeterminada: false,
    );

    final item = (rutina: rutinaClonada, alumno: alumno);
    final previousRutinas = List<({Rutina rutina, Alumno alumno})>.from(_rutinas);

    setState(() {
      _rutinas.insert(0, item);
      if (_rutinas.length > 10) _rutinas.removeLast();
    });

    _addGenericRoutineBackground(r, alumno, rutinaClonada, previousRutinas);
  }

  Future<void> _addGenericRoutineBackground(
    Rutina r, 
    Alumno alumno, 
    Rutina rutinaClonada, 
    List<({Rutina rutina, Alumno alumno})> previousRutinas
  ) async {
    try {
      final repo = ref.read(routineRepositoryProvider);

      final rutinaCompleta = await repo.getRutinaCompleta(r.idRutina!);
      if (rutinaCompleta == null) {
        throw Exception('No se pudo cargar la rutina original');
      }

      final rutinaConDias = rutinaClonada.copyWith(dias: rutinaCompleta.dias);

      final rutinasAlumno = await repo.getRutinasPorAlumno(alumno.idAlumno);
      if (rutinasAlumno.length >= 3) {
        final masAntigua = rutinasAlumno.last;
        if (masAntigua.rutina.urlPdf != null) {
          await StorageService().deletePdf(urlPdf: masAntigua.rutina.urlPdf!);
        }
        await repo.deleteRoutine(masAntigua.rutina.idRutina!);
      }

      final newId = await repo.saveRoutine(rutinaConDias);

      final pdfGenerator = PdfGenerator();
      final newPdfBytes = await pdfGenerator.generate(
        rutina: rutinaConDias.copyWith(idRutina: newId),
        alumno: alumno,
      );

      final storage = StorageService();
      final newPdfUrl = await storage.uploadPdf(
        bytes: newPdfBytes,
        idRutina: newId,
        nombreAlumno: alumno.nombreCompleto,
      );

      await repo.updatePdfUrl(idRutina: newId, url: newPdfUrl);

      if (alumno.mail != null && alumno.mail!.isNotEmpty) {
        await EmailService().enviarRutina(
          pdfUrl: newPdfUrl,
          mailAlumno: alumno.mail!,
          nombreAlumno: alumno.nombreCompleto,
          nombreRutina: rutinaConDias.nombre,
        );
      }

      if (mounted) {
        setState(() {
          final idx = _rutinas.indexWhere(
            (element) => element.rutina.idRutina == rutinaClonada.idRutina
          );
          if (idx != -1) {
            _rutinas[idx] = (
              rutina: rutinaConDias.copyWith(idRutina: newId, urlPdf: newPdfUrl),
              alumno: alumno
            );
          }
        });
        GlobalMessenger.showSuccessSnackbar('Rutina asignada y enviada a ${alumno.mail}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _rutinas = previousRutinas);
        GlobalMessenger.showErrorSnackbar('Ocurrió un error inesperado al asignar la rutina. Verifica tu conexión e intenta de nuevo.');
      }
    }
  }

  Future<void> _showAsignarRutinaForm(Rutina rutinaInicial) async {
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
            child: AsignarRutinaForm(
              alumnoRepository: ref.read(alumnoRepositoryProvider),
              rutinasPredeterminadas: _rutinasPredeterminadas,
              rutinaSeleccionadaInicial: rutinaInicial,
              onCancelar: () => Navigator.of(dialogContext).pop(),
              onAsignar: (alumno, rutinaP) async {
                Navigator.of(dialogContext).pop();
                _addGenericRoutine(rutinaP, alumno);
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
                await ref.read(authServiceProvider).signOut();
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
                        final result = await context
                            .push<({Rutina rutina, Alumno alumno, Future<Rutina> future})?>(
                              '/crear-rutina',
                            );
                        if (result != null) {
                          setState(() {
                            _rutinas.insert(0, (rutina: result.rutina, alumno: result.alumno));
                            if (_rutinas.length > 10) _rutinas.removeLast();
                          });

                          try {
                            final realRutina = await result.future;
                            if (mounted) {
                              setState(() {
                                final idx = _rutinas.indexWhere((r) => r.rutina.idRutina == result.rutina.idRutina);
                                if (idx != -1) _rutinas[idx] = (rutina: realRutina, alumno: result.alumno);
                              });
                            }
                          } catch (_) {
                            if (mounted) {
                              setState(() {
                                _rutinas.removeWhere((r) => r.rutina.idRutina == result.rutina.idRutina);
                              });
                            }
                          }
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
                              constraints: const BoxConstraints(maxWidth: 1200),
                              child: Column(
                                children: [
                                  SolicitudesPanel(
                                    solicitudes: _solicitudes,
                                    onRegistrarSolicitud:
                                        _showRegistrarSolicitudForm,
                                    onResolverSolicitud: (solicitud) async {
                                      final result = await context.push<({Rutina rutina, Alumno alumno, Future<Rutina> future})?>(
                                        '/crear-rutina',
                                        extra: solicitud,
                                      );
                                      if (result != null) {
                                        _eliminarSolicitudLocal(solicitud);
                                        setState(() {
                                          _rutinas.insert(0, (rutina: result.rutina, alumno: result.alumno));
                                          if (_rutinas.length > 10) _rutinas.removeLast();
                                        });

                                        try {
                                          final realRutina = await result.future;
                                          if (mounted) {
                                            setState(() {
                                              final idx = _rutinas.indexWhere((r) => r.rutina.idRutina == result.rutina.idRutina);
                                              if (idx != -1) _rutinas[idx] = (rutina: realRutina, alumno: result.alumno);
                                            });
                                          }
                                        } catch (_) {
                                          if (mounted) {
                                            setState(() {
                                              _rutinas.removeWhere((r) => r.rutina.idRutina == result.rutina.idRutina);
                                            });
                                          }
                                        }
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
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: RutinasPanel(
                                          rutinas: _rutinas,
                                          onVerDetalle: (rutina) async {
                                            if (rutina.urlPdf != null) {
                                              final uri = Uri.parse(
                                                rutina.urlPdf!,
                                              );
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(
                                                  uri,
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              }
                                            }
                                          },
                                          onEditarRutina: (rutina) async {
                                            final result =
                                                await context.push<
                                                  ({
                                                    Rutina rutina,
                                                    Alumno alumno,
                                                    Future<Rutina> future
                                                  })?
                                                >(
                                                  '/editar-rutina',
                                                  extra: rutina,
                                                );
                                            if (result != null) {
                                              setState(() {
                                                final index = _rutinas
                                                    .indexWhere(
                                                      (r) =>
                                                          r.rutina.idRutina ==
                                                          result
                                                              .rutina
                                                              .idRutina,
                                                    );
                                                if (index != -1) {
                                                  _rutinas[index] = (rutina: result.rutina, alumno: result.alumno);
                                                }
                                              });

                                              try {
                                                final realRutina = await result.future;
                                                if (mounted) {
                                                  setState(() {
                                                    final idx = _rutinas.indexWhere((r) => r.rutina.idRutina == result.rutina.idRutina);
                                                    if (idx != -1) _rutinas[idx] = (rutina: realRutina, alumno: result.alumno);
                                                  });
                                                }
                                              } catch (_) {
                                                // On edit error, we could revert to original. For now we just let it be or reload
                                                _loadRutinas();
                                              }
                                            }
                                          },
                                          onEliminarRutina: (rutina) async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) =>
                                                  DeleteConfirmDialog(
                                                    title: 'Eliminar rutina',
                                                    message:
                                                        '¿Estás seguro de que quieres eliminar la rutina "${rutina.nombre}"? Esta acción no se puede deshacer.',
                                                  ),
                                            );
                                            if (confirm == true) {
                                              try {
                                                final repo = ref.read(
                                                  routineRepositoryProvider,
                                                );
                                                final storage =
                                                    StorageService();
                                                if (rutina.urlPdf != null) {
                                                  await storage.deletePdf(
                                                    urlPdf: rutina.urlPdf!,
                                                  );
                                                }
                                                await repo.deleteRoutine(
                                                  rutina.idRutina!,
                                                );
                                                if (mounted) {
                                                  setState(() {
                                                    _rutinas.removeWhere(
                                                      (r) =>
                                                          r.rutina.idRutina ==
                                                          rutina.idRutina,
                                                    );
                                                  });
                                                  GlobalMessenger.showSuccessSnackbar('Rutina eliminada exitosamente');
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  GlobalMessenger.showErrorSnackbar('Ocurrió un error inesperado al eliminar la rutina. Verifica tu conexión e intenta de nuevo.');
                                                }
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xl),
                                      Expanded(
                                        child: RutinasPredeterminadasPanel(
                                          rutinas: _rutinasPredeterminadas,
                                          onNuevaRutina: () async {
                                            final result = await context
                                                .push<(Rutina, Future<Rutina>)?>(
                                                  '/nueva-rutina-predeterminada',
                                                );
                                            if (result != null) {
                                              final (rutinaLocal, future) = result;
                                              setState(() {
                                                _rutinasPredeterminadas.insert(0, rutinaLocal);
                                              });
                                              try {
                                                final realRutina = await future;
                                                if (mounted) {
                                                  setState(() {
                                                    final idx = _rutinasPredeterminadas.indexWhere((r) => r.idRutina == rutinaLocal.idRutina);
                                                    if (idx != -1) _rutinasPredeterminadas[idx] = realRutina;
                                                  });
                                                }
                                              } catch (_) {
                                                if (mounted) {
                                                  setState(() {
                                                    _rutinasPredeterminadas.removeWhere((r) => r.idRutina == rutinaLocal.idRutina);
                                                  });
                                                }
                                              }
                                            }
                                          },
                                          onVerDetalle: (rutina) async {
                                            if (rutina.urlPdf != null) {
                                              final uri = Uri.parse(
                                                rutina.urlPdf!,
                                              );
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(
                                                  uri,
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              }
                                            }
                                          },
                                          onEditarRutina: (rutina) async {
                                            final result =
                                                await context.push<(Rutina, Future<Rutina>)?>(
                                                  '/editar-rutina',
                                                  extra: rutina,
                                                );
                                            if (result != null) {
                                              final (rutinaLocal, future) = result;
                                              setState(() {
                                                final index =
                                                    _rutinasPredeterminadas
                                                        .indexWhere(
                                                          (r) =>
                                                              r.idRutina ==
                                                              rutinaLocal
                                                                  .idRutina,
                                                        );
                                                if (index != -1) {
                                                  _rutinasPredeterminadas[index] =
                                                      rutinaLocal;
                                                }
                                              });
                                              try {
                                                final realRutina = await future;
                                                if (mounted) {
                                                  setState(() {
                                                    final idx = _rutinasPredeterminadas.indexWhere((r) => r.idRutina == rutinaLocal.idRutina);
                                                    if (idx != -1) _rutinasPredeterminadas[idx] = realRutina;
                                                  });
                                                }
                                              } catch (_) {
                                                _loadRutinasPredeterminadas();
                                              }
                                            }
                                          },
                                          onEliminarRutina: (rutina) async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) =>
                                                  DeleteConfirmDialog(
                                                    title: 'Eliminar rutina',
                                                    message:
                                                        '¿Estás seguro de que quieres eliminar la rutina "${rutina.nombre}"? Esta acción no se puede deshacer.',
                                                  ),
                                            );
                                            if (confirm == true) {
                                              try {
                                                final repo = ref.read(
                                                  routineRepositoryProvider,
                                                );
                                                final storage =
                                                    StorageService();
                                                if (rutina.urlPdf != null) {
                                                  await storage.deletePdf(
                                                    urlPdf: rutina.urlPdf!,
                                                  );
                                                }
                                                await repo.deleteRoutine(
                                                  rutina.idRutina!,
                                                );
                                                if (mounted) {
                                                  setState(() {
                                                    _rutinasPredeterminadas
                                                        .removeWhere(
                                                          (r) =>
                                                              r.idRutina ==
                                                              rutina.idRutina,
                                                        );
                                                  });
                                                  GlobalMessenger.showSuccessSnackbar('Rutina eliminada exitosamente');
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  GlobalMessenger.showErrorSnackbar('Ocurrió un error inesperado al eliminar la rutina. Verifica tu conexión e intenta de nuevo.');
                                                }
                                              }
                                            }
                                          },
                                          onAsignarRutina:
                                              _showAsignarRutinaForm,
                                        ),
                                      ),
                                    ],
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
