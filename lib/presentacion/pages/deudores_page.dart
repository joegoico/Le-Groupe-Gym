import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:le_groupe_gym/data/models/deudor_model.dart';
import 'package:le_groupe_gym/presentacion/builder/sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/top_bar.dart';
import 'package:le_groupe_gym/presentacion/pages/deudores_widgets/deudor_card.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:le_groupe_gym/presentacion/forms/pago_form.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/logout_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/delete_confirm_dialog.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/presentacion/builder/alumno_selector.dart';

class DeudoresPage extends ConsumerStatefulWidget {
  const DeudoresPage({super.key});

  @override
  ConsumerState<DeudoresPage> createState() => _DeudoresPageState();
}

class _DeudoresPageState extends ConsumerState<DeudoresPage> {
  bool _isLoading = true;
  bool _sidebarCollapsed = false;
  List<Deudor> _deudores = [];
  String _filtroSeleccionado = 'Todos';
  Alumno? _alumnoFiltro;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repo = ref.read(deudorRepositoryProvider);
      final deudores = await repo.getDeudores();
      if (mounted) {
        setState(() {
          _deudores = deudores;
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
      body: Row(
        children: [
          Sidebar(
            currentRoute: '/deudores',
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
                  pageTitle: 'Deudores',
                  actionsCenter: [
                    SizedBox(
                      width: 320,
                      child: AlumnoSelector(
                        alumnoRepository: ref.read(alumnoRepositoryProvider),
                        alumnoSeleccionado: _alumnoFiltro,
                        hintText: 'Buscar por nombre...',
                        onAlumnoChanged: (alumno) {
                          setState(() {
                            _alumnoFiltro = alumno;
                          });
                        },
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
    // Filtrar deudores
    final deudoresFiltrados = _deudores.where((d) {
      if (_alumnoFiltro != null && d.idDeudor != _alumnoFiltro!.idAlumno) {
        return false;
      }
      
      if (_filtroSeleccionado == 'Vencido este mes') {
        return d.diasAdeudados < 30;
      } else if (_filtroSeleccionado == 'Más de 30 días') {
        return d.diasAdeudados >= 30 && d.diasAdeudados <= 60;
      } else if (_filtroSeleccionado == 'Más de 60 días') {
        return d.diasAdeudados > 60;
      }
      return true; // 'Todos'
    }).toList();

    if (_deudores.isEmpty) {
      return Center(
        child: Text(
          'No hay deudores registrados',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deudores',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Filtros
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              'Todos',
              'Vencido este mes',
              'Más de 30 días',
              'Más de 60 días'
            ].map((filtro) {
              final isSelected = _filtroSeleccionado == filtro;
              return ChoiceChip(
                label: Text(
                  filtro,
                  style: GoogleFonts.inter(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.black : AppColors.onSurfaceVariant,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _filtroSeleccionado = filtro;
                    });
                  }
                },
                selectedColor: const Color(0xFFD0FD38),
                backgroundColor: AppColors.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFD0FD38) : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 220,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: deudoresFiltrados.length,
              itemBuilder: (gridContext, index) {
                final deudor = deudoresFiltrados[index];
                return DeudorCard(
                  deudor: deudor,
                  onRegistrarPago: () async {
                    setState(() => _isLoading = true);
                    try {
                      final alumnoRepo = ref.read(alumnoRepositoryProvider);
                      final alumno = await alumnoRepo.getAlumnoById(deudor.idDeudor);
                      
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                      
                      if (alumno != null) {
                        showDialog(
                          context: context, // Usamos el context del State
                          builder: (ctx) => PagoForm(alumno: alumno),
                        ).then((_) {
                          if (!mounted) return;
                          setState(() => _isLoading = true);
                          _loadData();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error: No se encontró el alumno.')),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  onEliminar: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => DeleteConfirmDialog(
                        title: 'Eliminar deudor',
                        message: '¿Seguro que querés eliminar a ${deudor.nombreCompleto} de la lista de deudores? Esta acción no se puede deshacer.',
                      ),
                    );

                    if (confirmar != true) return;

                    setState(() => _isLoading = true);
                    try {
                      final repo = ref.read(deudorRepositoryProvider);
                      await repo.eliminarDeudor(deudor.idDeudor);
                      
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Deudor eliminado exitosamente.',
                            style: GoogleFonts.inter(
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
                      
                      setState(() => _isLoading = true);
                      _loadData();
                    } catch (e) {
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al eliminar deudor: $e')),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
