import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';
import 'package:le_groupe_gym/presentacion/builder/sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/show_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/top_bar.dart';
import 'package:le_groupe_gym/presentacion/forms/alumno_form.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Paleta de colores para avatares ─────────────────────────────────────────
const _avatarColors = [
  Color(0xFF5C6BC0), // índigo
  Color(0xFF26A69A), // teal
  Color(0xFFEF5350), // rojo
  Color(0xFF42A5F5), // azul
  Color(0xFFAB47BC), // púrpura
  Color(0xFF66BB6A), // verde
  Color(0xFFFFA726), // naranja
  Color(0xFF26C6DA), // cyan
];

Color _avatarColor(String nombre) =>
    _avatarColors[nombre.codeUnitAt(0) % _avatarColors.length];

// ── Página ───────────────────────────────────────────────────────────────────

class AlumnosPage extends ConsumerStatefulWidget {
  const AlumnosPage({super.key});

  @override
  ConsumerState<AlumnosPage> createState() => _AlumnosPageState();
}

class _AlumnosPageState extends ConsumerState<AlumnosPage> {
  bool _isLoading = true;
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
      final alumnos = await repo.getAlumnos();
      if (mounted) {
        setState(() {
          _alumnos = alumnos;
          _alumnosFiltrados = alumnos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onAlumnoChanged(Alumno? alumno) {
    setState(() {
      _alumnoSeleccionado = alumno;
      _alumnosFiltrados = alumno != null ? [alumno] : _alumnos;
    });
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

  Future<void> _abrirFormulario({Alumno? alumno}) async {
    await showDialog<void>(
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
          onGuardar: (alumnoGuardado) {
            Navigator.of(dialogContext).pop();
            _onAlumnoGuardado(alumnoGuardado, esEdicion: alumno != null);
          },
        ),
      ),
    );
  }

  void _onAlumnoGuardado(Alumno alumno, {required bool esEdicion}) {
    if (esEdicion) {
      setState(() {
        final idx = _alumnos.indexWhere((a) => a.idAlumno == alumno.idAlumno);
        if (idx != -1) _alumnos[idx] = alumno;
        final idxF = _alumnosFiltrados.indexWhere(
          (a) => a.idAlumno == alumno.idAlumno,
        );
        if (idxF != -1) _alumnosFiltrados[idxF] = alumno;
      });
    } else {
      setState(() {
        _alumnos.insert(0, alumno);
        _alumnosFiltrados.insert(0, alumno);
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
    final confirmar = await showConfirmDialog(
      context,
      titulo: 'Eliminar alumno',
      mensaje:
          '¿Seguro que querés eliminar a ${alumno.nombreCompleto}? Esta acción no se puede deshacer.',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
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
              await SupabaseConfig.client.auth.signOut();
              if (mounted) context.go('/login');
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
                          onVerPagos: () {/* TODO */},
                          onVerRutinas: () {/* TODO */},
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }
}

// ── AlumnoCard ───────────────────────────────────────────────────────────────

class AlumnoCard extends StatelessWidget {
  final Alumno alumno;
  final VoidCallback onEliminar;
  final VoidCallback onEditar;
  final VoidCallback onVerPagos;
  final VoidCallback onVerRutinas;

  const AlumnoCard({
    super.key,
    required this.alumno,
    required this.onEliminar,
    required this.onEditar,
    required this.onVerPagos,
    required this.onVerRutinas,
  });

  @override
  Widget build(BuildContext context) {
    final initials =
        '${alumno.nombre.isNotEmpty ? alumno.nombre[0] : ''}${alumno.apellido.isNotEmpty ? alumno.apellido[0] : ''}'
            .toUpperCase();
    final avatarColor = _avatarColor(alumno.nombre);

    return Container(
      width: 180,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fila superior: avatar + acciones ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              _ActionIcon(
                key: Key('eliminar_${alumno.idAlumno}'),
                icon: Icons.delete_outline,
                onTap: onEliminar,
              ),
              const SizedBox(width: 4),
              _ActionIcon(
                key: Key('editar_${alumno.idAlumno}'),
                icon: Icons.edit_outlined,
                onTap: onEditar,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Nombre ────────────────────────────────────────────────────
          Text(
            alumno.nombreCompleto,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // ── Subtítulo ─────────────────────────────────────────────────
          Text(
            alumno.aplicaDescuento ? 'Con descuento' : 'Sin descuento',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: alumno.aplicaDescuento
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Acciones inferiores ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  key: Key('ver_pagos_${alumno.idAlumno}'),
                  onPressed: onVerPagos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.sm),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  child: const Text('VER PAGOS'),
                ),
              ),
              const SizedBox(width: 6),
              _ActionIcon(
                key: Key('rutinas_${alumno.idAlumno}'),
                icon: Icons.fitness_center_outlined,
                onTap: onVerRutinas,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widget auxiliar: ícono de acción pequeño ─────────────────────────────────

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _ActionIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: size,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
