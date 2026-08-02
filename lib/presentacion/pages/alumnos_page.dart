import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import 'package:le_groupe_gym/presentacion/builder/sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/delete_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/logout_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/top_bar.dart';
import 'package:le_groupe_gym/presentacion/forms/alumno_form.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:le_groupe_gym/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'alumnos_widgets/alumnos_card.dart';
// ── Página ───────────────────────────────────────────────────────────────────

class AlumnosPage extends ConsumerStatefulWidget {
  const AlumnosPage({super.key});

  @override
  ConsumerState<AlumnosPage> createState() => _AlumnosPageState();
}

class _AlumnosPageState extends ConsumerState<AlumnosPage> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _sidebarCollapsed = false;
  List<Alumno> _alumnos = [];
  List<Alumno> _alumnosFiltrados = [];
  Alumno? _alumnoSeleccionado;

  @override
  void initState() {
    super.initState();
    _loadAlumnos();
  }

  Future<void> _loadAlumnos() async {
    try {
      final repo = ref.read(alumnoRepositoryProvider);
      final alumnos = await repo.getAlumnos(limit: 50, offset: 0);
      if (mounted) {
        setState(() {
          _alumnos = alumnos;
          _alumnosFiltrados = List<Alumno>.from(alumnos); // copia independiente
          _hasMore = alumnos.length == 50;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreAlumnos() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    
    try {
      final repo = ref.read(alumnoRepositoryProvider);
      final offset = _alumnos.length;
      final newAlumnos = await repo.getAlumnos(limit: 50, offset: offset);
      
      if (mounted) {
        if (newAlumnos.isEmpty) {
          setState(() {
            _hasMore = false;
            _isLoadingMore = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No hay más alumnos para cargar', style: AppTextStyles.subtittlesBold),
              backgroundColor: AppColors.surfaceContainerHigh,
            ),
          );
          return;
        }

        setState(() {
          _alumnos.addAll(newAlumnos);
          if (_alumnoSeleccionado == null) {
            _alumnosFiltrados = List<Alumno>.from(_alumnos);
          }
          _hasMore = newAlumnos.length == 50;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar más alumnos: $e')),
        );
      }
    }
  }

  void _onAlumnoChanged(Alumno? alumno) {
    setState(() {
      _alumnoSeleccionado = alumno;
      _alumnosFiltrados = alumno != null
          ? [alumno]
          : List<Alumno>.from(_alumnos);
    });
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

  Future<void> _abrirFormulario({Alumno? alumno}) async {
    final alumnoGuardado = await showDialog<Alumno>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: AlumnoForm(
          alumno: alumno,
          alumnoRepository: ref.read(alumnoRepositoryProvider),
          onCancelar: () => Navigator.of(dialogContext).pop(),
          onGuardar: (saved) => Navigator.of(dialogContext).pop(saved),
        ),
      ),
    );

    if (alumnoGuardado != null) {
      _onAlumnoGuardado(alumnoGuardado, esEdicion: alumno != null);
    }
  }

  void _onAlumnoGuardado(Alumno alumno, {required bool esEdicion}) {
    if (esEdicion) {
      setState(() {
        final idx = _alumnos.indexWhere((a) => a.idAlumno == alumno.idAlumno);
        if (idx != -1) _alumnos[idx] = alumno;
        // _alumnosFiltrados se deriva de _alumnos para mantener consistencia
        _alumnosFiltrados = _alumnoSeleccionado == null
            ? List<Alumno>.from(_alumnos)
            : [alumno];
      });
    } else {
      setState(() {
        _alumnos.insert(0, alumno);
        // deriva la lista filtrada a partir de la fuente de verdad
        if (_alumnoSeleccionado == null) {
          _alumnosFiltrados = List<Alumno>.from(_alumnos);
        }
      });
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            esEdicion
                ? 'Alumno actualizado correctamente'
                : 'Alumno creado correctamente',
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
    }
  }

  Future<void> _eliminarAlumno(Alumno alumno) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmDialog(
        title: 'Eliminar alumno',
        message: '¿Seguro que querés eliminar a ${alumno.nombreCompleto}? Esta acción no se puede deshacer.',
      ),
    );
    if (confirmar != true) return;

    try {
      await ref.read(alumnoRepositoryProvider).deleteAlumno(alumno.idAlumno);
      if (mounted) {
        setState(() {
          _alumnos.removeWhere((a) => a.idAlumno == alumno.idAlumno);
          _alumnosFiltrados.removeWhere((a) => a.idAlumno == alumno.idAlumno);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Alumno eliminado',
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Sidebar(
            currentRoute: '/alumnos',
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
                  pageTitle: 'Alumnos',
                  actionsCenter: [
                    SizedBox(
                      width: 320,
                      child: AlumnoSelector(
                        key: const Key('alumnos_search_selector'),
                        alumnoRepository: ref.read(alumnoRepositoryProvider),
                        alumnoSeleccionado: _alumnoSeleccionado,
                        hintText: 'Buscar por nombre...',
                        onAlumnoChanged: _onAlumnoChanged,
                      ),
                    ),
                  ],
                  actionsEnd: [
                    ElevatedButton.icon(
                      onPressed: () => _abrirFormulario(),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        'Nuevo Alumno',
                        style: AppTextStyles.buttonText,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(AppRadius.md),
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
                      : _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Contador ──────────────────────────────────────────────────
          Text(
            '${_alumnosFiltrados.length} alumno${_alumnosFiltrados.length == 1 ? '' : 's'}',
            style: AppTextStyles.labelCaps,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Grid de cards ─────────────────────────────────────────────
          _alumnosFiltrados.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Text(
                      'No se encontraron alumnos.',
                      style: AppTextStyles.subtittles,
                    ),
                  ),
                )
              : Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: _alumnosFiltrados
                      .map(
                        (alumno) => AlumnoCard(
                          alumno: alumno,
                          onEliminar: () => _eliminarAlumno(alumno),
                          onEditar: () => _abrirFormulario(alumno: alumno),
                          onVerDetalles: () {
                            context.push('/alumnos/detalle', extra: alumno);
                          },
                          onVerPagos: () {
                            context.push('/alumnos/pagos', extra: alumno);
                          },
                        ),
                      )
                      .toList(),
                ),
          if (_alumnoSeleccionado == null && _hasMore && _alumnosFiltrados.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.lg),
              child: Center(
                child: _isLoadingMore
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : ElevatedButton(
                        onPressed: _loadMoreAlumnos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          'Cargar Más',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
