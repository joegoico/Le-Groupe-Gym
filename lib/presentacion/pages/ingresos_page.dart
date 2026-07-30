import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:le_groupe_gym/data/models/ingreso_model.dart';
import 'package:le_groupe_gym/data/models/resumen_mensual_model.dart';
import 'package:le_groupe_gym/presentacion/builder/sidebar.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/logout_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/top_bar.dart';
import 'package:le_groupe_gym/presentacion/pages/ingresos_widgets/resumen_mensual_card.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────

enum _Filtro { hoy, mesActual, fechaEspecifica, rangoDeFechas }

// ─────────────────────────────────────────────────────────────────────────────

class IngresoPage extends ConsumerStatefulWidget {
  const IngresoPage({super.key});

  @override
  ConsumerState<IngresoPage> createState() => _IngresoPageState();
}

class _IngresoPageState extends ConsumerState<IngresoPage> {
  bool _isLoading = true;
  bool _sidebarCollapsed = false;

  /// null = sin filtro → carga todos los ingresos
  _Filtro? _filtroActivo;
  DateTime? _fechaFiltro;
  DateTimeRange? _rangoFiltro;

  List<Ingreso> _ingresos = [];

  @override
  void initState() {
    super.initState();
    _loadIngresos();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> _loadIngresos() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(ingresoRepositoryProvider);
      final List<Ingreso> result;

      if (_filtroActivo == _Filtro.hoy) {
        final hoy = DateTime.now();
        result = await repo.getIngresosPorFecha(fecha: hoy);
      } else if (_filtroActivo == _Filtro.mesActual) {
        final now = DateTime.now();
        result = await repo.getIngresosPorPeriodo(
          desde: DateTime(now.year, now.month, 1),
          hasta: DateTime(now.year, now.month + 1, 0),
        );
      } else if (_filtroActivo == _Filtro.fechaEspecifica &&
          _fechaFiltro != null) {
        result = await repo.getIngresosPorFecha(fecha: _fechaFiltro!);
      } else if (_filtroActivo == _Filtro.rangoDeFechas &&
          _rangoFiltro != null) {
        result = await repo.getIngresosPorPeriodo(
          desde: _rangoFiltro!.start,
          hasta: _rangoFiltro!.end,
        );
      } else {
        // Sin filtro → todos
        result = await repo.getIngresos();
      }

      if (mounted) setState(() => _ingresos = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar ingresos: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Filtros ───────────────────────────────────────────────────────────────

  Widget _datePickerTheme(BuildContext ctx, Widget? child) => Theme(
    data: Theme.of(ctx).copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surfaceContainerHigh,
        onSurface: AppColors.onSurface,
      ),
    ),
    child: child!,
  );

  Future<void> _onChipTapped(_Filtro filtro) async {
    // Toggle off si ya está activo
    if (_filtroActivo == filtro) {
      setState(() {
        _filtroActivo = null;
        _fechaFiltro = null;
        _rangoFiltro = null;
      });
      _loadIngresos();
      return;
    }

    if (filtro == _Filtro.fechaEspecifica) {
      final picked = await showDatePicker(
        context: context,
        initialDate: _fechaFiltro ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        builder: _datePickerTheme,
      );
      if (!mounted || picked == null) return;
      setState(() {
        _filtroActivo = filtro;
        _fechaFiltro = picked;
        _rangoFiltro = null;
      });
    } else if (filtro == _Filtro.rangoDeFechas) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        initialDateRange: _rangoFiltro,
        builder: _datePickerTheme,
      );
      if (!mounted || picked == null) return;
      setState(() {
        _filtroActivo = filtro;
        _rangoFiltro = picked;
        _fechaFiltro = null;
      });
    } else {
      // Mes actual — activa directo
      setState(() {
        _filtroActivo = filtro;
        _fechaFiltro = null;
        _rangoFiltro = null;
      });
    }

    _loadIngresos();
  }

  // ── Agrupación ────────────────────────────────────────────────────────────

  List<ResumenMensual> get _resumenes {
    final Map<String, List<Ingreso>> grupos = {};
    for (final i in _ingresos) {
      final key =
          '${i.fechaIngreso.year}-${i.fechaIngreso.month.toString().padLeft(2, '0')}';
      grupos.putIfAbsent(key, () => []).add(i);
    }
    return grupos.entries.map((e) {
      final parts = e.key.split('-');
      return ResumenMensual(
        mes: int.parse(parts[1]),
        anio: int.parse(parts[0]),
        ingresos: e.value,
      );
    }).toList()..sort((a, b) {
      final dateA = DateTime(a.anio, a.mes);
      final dateB = DateTime(b.anio, b.mes);
      return dateB.compareTo(dateA);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /* TODO: abrir form ingreso */
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        tooltip: 'Agregar Ingreso',
        child: const Icon(Icons.add),
      ),
      body: Row(
        children: [
          Sidebar(
            currentRoute: '/ingresos',
            isCollapsed: _sidebarCollapsed,
            onCerrarSesion: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => const LogoutConfirmDialog(),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // — Top Bar —
                TopBar(
                  onMenuPressed: () =>
                      setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                  pageTitle: 'Ingresos',
                  actionsEnd: [
                    ElevatedButton.icon(
                      onPressed: () {
                        /* TODO */
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        'Agregar Ingreso',
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

                // — ChoiceChips debajo de TopBar —
                _FiltroChips(
                  filtroActivo: _filtroActivo,
                  fechaFiltro: _fechaFiltro,
                  rangoFiltro: _rangoFiltro,
                  onChipTapped: _onChipTapped,
                  onLimpiar: _filtroActivo != null
                      ? () {
                          setState(() {
                            _filtroActivo = null;
                            _fechaFiltro = null;
                            _rangoFiltro = null;
                          });
                          _loadIngresos();
                        }
                      : null,
                ),

                // — Contenido —
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : _buildGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final resumenes = _resumenes;
    if (resumenes.isEmpty) {
      return Center(
        child: Text(
          _filtroActivo != null
              ? 'No hay ingresos para el período seleccionado.'
              : 'No hay ingresos registrados.',
          style: AppTextStyles.subtittles,
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: resumenes
            .map(
              (r) => SizedBox(
                width: 380,
                child: ResumenMensualCard(
                  resumen: r,
                  onVerDetalle: () =>
                      context.push('/ingresos/detalle', extra: r),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FiltroChips extends StatelessWidget {
  final _Filtro? filtroActivo;
  final DateTime? fechaFiltro;
  final DateTimeRange? rangoFiltro;
  final void Function(_Filtro) onChipTapped;
  final VoidCallback? onLimpiar;

  const _FiltroChips({
    required this.filtroActivo,
    required this.fechaFiltro,
    required this.rangoFiltro,
    required this.onChipTapped,
    this.onLimpiar,
  });

  String _labelFor(_Filtro filtro) {
    final fmtShort = DateFormat('d MMM', 'es');
    switch (filtro) {
      case _Filtro.hoy:
        return 'Hoy · ${fmtShort.format(DateTime.now())}';
      case _Filtro.mesActual:
        return 'Mes Actual';
      case _Filtro.fechaEspecifica:
        if (filtroActivo == _Filtro.fechaEspecifica && fechaFiltro != null) {
          return fmtShort.format(fechaFiltro!);
        }
        return 'Fecha Específica';
      case _Filtro.rangoDeFechas:
        if (filtroActivo == _Filtro.rangoDeFechas && rangoFiltro != null) {
          return '${fmtShort.format(rangoFiltro!.start)} → ${fmtShort.format(rangoFiltro!.end)}';
        }
        return 'Rango de Fechas';
    }
  }

  @override
  Widget build(BuildContext context) {
    const opciones = [
      _Filtro.hoy,
      _Filtro.fechaEspecifica,
      _Filtro.rangoDeFechas,
      _Filtro.mesActual,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          // — Título —
          Text('Filtrar por', style: AppTextStyles.labelCaps),
          const SizedBox(width: AppSpacing.md),

          // — Chips —
          for (final filtro in opciones)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(
                  _labelFor(filtro),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: filtroActivo == filtro
                        ? AppColors.onPrimary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                selected: filtroActivo == filtro,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceContainerHigh,
                side: BorderSide(
                  color: filtroActivo == filtro
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                ),
                showCheckmark: false,
                onSelected: (_) => onChipTapped(filtro),
              ),
            ),

          // — Limpiar (solo si hay filtro activo) —
          if (onLimpiar != null) ...[
            const SizedBox(width: AppSpacing.xs),
            InkWell(
              onTap: onLimpiar,
              borderRadius: const BorderRadius.all(AppRadius.full),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Limpiar',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
