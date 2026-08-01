import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:le_groupe_gym/services/pdf_generator.dart';
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
  final List<SolicitudRutina> _recentlyCreatedSolicitudes = [];
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

  Future<void> _addGenericRoutine(Rutina r, Alumno alumno) async {
    try {
      setState(() => _isLoading = true);
      final repo = ref.read(routineRepositoryProvider);

      // 1. Obtener la rutina completa (con días, bloques, etc)
      final rutinaCompleta = await repo.getRutinaCompleta(r.idRutina!);
      if (rutinaCompleta == null)
        throw Exception('No se pudo cargar la rutina original');

      // 2. Clonarla para este alumno (instanciamos nueva para borrar el ID)
      final rutinaClonada = Rutina(
        idAlumno: alumno.idAlumno,
        nombre: rutinaCompleta.nombre,
        dias: rutinaCompleta.dias,
        fechaCreacion: DateTime.now(),
        notasGenerales: rutinaCompleta.notasGenerales,
        urlPdf: null,
        esPredeterminada: false,
      );

      // 3. Chequear si el alumno ya tiene 3 rutinas y borrar la más antigua
      final rutinasAlumno = await repo.getRutinasPorAlumno(alumno.idAlumno);
      if (rutinasAlumno.length >= 3) {
        final masAntigua = rutinasAlumno.last;
        if (masAntigua.rutina.urlPdf != null) {
          await StorageService().deletePdf(
            urlPdf: masAntigua.rutina.urlPdf!,
          );
        }
        await repo.deleteRoutine(masAntigua.rutina.idRutina!);
      }

      // 4. Guardar la nueva rutina
      final newId = await repo.saveRoutine(rutinaClonada);

      // 5. Generar PDF
      final pdfGenerator = PdfGenerator();
      final newPdfBytes = await pdfGenerator.generate(
        rutina: rutinaClonada,
        alumno: alumno,
      );

      // 6. Subir PDF a Storage
      final storage = StorageService();
      final newPdfUrl = await storage.uploadPdf(
        bytes: newPdfBytes,
        idRutina: newId,
        nombreAlumno: alumno.nombreCompleto,
      );

      // 7. Actualizar URL en la BD
      await repo.updatePdfUrl(idRutina: newId, url: newPdfUrl);

      // 8. Enviar correo al alumno
      await EmailService().enviarRutina(
        pdfUrl: newPdfUrl,
        mailAlumno: alumno.mail!,
        nombreAlumno: alumno.nombreCompleto,
        nombreRutina: rutinaClonada.nombre,
      );

      if (mounted) {
        // Reflejamos los cambios en el UI localmente
        setState(() {
          final rFinal = rutinaClonada.copyWith(
            idRutina: newId,
            urlPdf: newPdfUrl,
          );
          _rutinas.insert(0, (rutina: rFinal, alumno: alumno));
          if (_rutinas.length > 10) {
            _rutinas.removeLast();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rutina asignada y enviada a ${alumno.mail}',
              style: AppTextStyles.subtittlesBold.copyWith(
                color: AppColors.successContent,
              ),
            ),
            backgroundColor: AppColors.successContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al asignar rutina: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                              constraints: const BoxConstraints(maxWidth: 1200),
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
                                            final rutinaActualizada =
                                                await context.push<
                                                  ({
                                                    Rutina rutina,
                                                    Alumno alumno,
                                                  })?
                                                >(
                                                  '/editar-rutina',
                                                  extra: rutina,
                                                );
                                            if (rutinaActualizada != null) {
                                              setState(() {
                                                final index = _rutinas
                                                    .indexWhere(
                                                      (r) =>
                                                          r.rutina.idRutina ==
                                                          rutinaActualizada
                                                              .rutina
                                                              .idRutina,
                                                    );
                                                if (index != -1) {
                                                  _rutinas[index] =
                                                      rutinaActualizada;
                                                }
                                              });
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
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Rutina eliminada exitosamente',
                                                      ),
                                                      backgroundColor: AppColors
                                                          .successContainer,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error al eliminar rutina: $e',
                                                      ),
                                                      backgroundColor:
                                                          AppColors.error,
                                                    ),
                                                  );
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
                                            final nuevaRutina = await context
                                                .push<Rutina?>(
                                                  '/nueva-rutina-predeterminada',
                                                );
                                            if (nuevaRutina != null) {
                                              setState(() {
                                                _rutinasPredeterminadas.insert(
                                                  0,
                                                  nuevaRutina,
                                                );
                                              });
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
                                            final rutinaActualizada =
                                                await context.push<Rutina?>(
                                                  '/editar-rutina',
                                                  extra: rutina,
                                                );
                                            if (rutinaActualizada != null) {
                                              setState(() {
                                                final index =
                                                    _rutinasPredeterminadas
                                                        .indexWhere(
                                                          (r) =>
                                                              r.idRutina ==
                                                              rutinaActualizada
                                                                  .idRutina,
                                                        );
                                                if (index != -1) {
                                                  _rutinasPredeterminadas[index] =
                                                      rutinaActualizada;
                                                }
                                              });
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
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Rutina eliminada exitosamente',
                                                      ),
                                                      backgroundColor: AppColors
                                                          .successContainer,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error: $e',
                                                      ),
                                                    ),
                                                  );
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
