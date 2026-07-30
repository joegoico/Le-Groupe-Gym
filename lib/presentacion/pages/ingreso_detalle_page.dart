import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/ingreso_model.dart';
import 'package:le_groupe_gym/data/models/resumen_mensual_model.dart';
import 'package:le_groupe_gym/presentacion/pages/ingresos_widgets/ingreso_filtros.dart';
import 'package:le_groupe_gym/presentacion/pages/ingresos_widgets/ingreso_table.dart';
import 'package:le_groupe_gym/presentacion/pages/ingresos_widgets/total_card.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────

enum _FiltroDetalle { fechaUnica, rango }

// ─────────────────────────────────────────────────────────────────────────────

class IngresoDetallePage extends ConsumerStatefulWidget {
  final ResumenMensual resumen;

  const IngresoDetallePage({super.key, required this.resumen});

  @override
  ConsumerState<IngresoDetallePage> createState() => _IngresoDetallePageState();
}

class _IngresoDetallePageState extends ConsumerState<IngresoDetallePage> {
  bool _isLoading = false;
  List<Ingreso> _ingresos = [];

  _FiltroDetalle? _filtroActivo;
  DateTime? _fechaUnica;
  DateTimeRange? _rango;

  final _fmtDisplay = DateFormat('dd/MM/yyyy', 'es');
  final _fmtLabel = DateFormat('d MMM yyyy', 'es');

  @override
  void initState() {
    super.initState();
    // Partimos con los ingresos del resumen recibido
    _ingresos = List.from(widget.resumen.ingresos);
  }

  // ── Computed ──────────────────────────────────────────────────────────────

  num get _totalEfectivo => _ingresos
      .where((i) => i.medioDePago?.toLowerCase() == 'efectivo')
      .fold(0, (s, i) => s + i.monto);

  num get _totalTransferencia => _ingresos
      .where((i) => i.medioDePago?.toLowerCase() == 'transferencia')
      .fold(0, (s, i) => s + i.monto);

  bool get _hayFiltro => _filtroActivo != null;

  String get _filtroDescripcion {
    if (_filtroActivo == _FiltroDetalle.fechaUnica && _fechaUnica != null) {
      return _fmtLabel.format(_fechaUnica!);
    }
    if (_filtroActivo == _FiltroDetalle.rango && _rango != null) {
      return '${_fmtLabel.format(_rango!.start)} → ${_fmtLabel.format(_rango!.end)}';
    }
    return '';
  }

  String? get _fechaUnicaLabel =>
      (_filtroActivo == _FiltroDetalle.fechaUnica && _fechaUnica != null)
      ? _fmtDisplay.format(_fechaUnica!)
      : null;

  String? get _rangoLabel =>
      (_filtroActivo == _FiltroDetalle.rango && _rango != null)
      ? '${_fmtDisplay.format(_rango!.start)}  →  ${_fmtDisplay.format(_rango!.end)}'
      : null;

  /// Primer día del mes del resumen (límite inferior del picker)
  DateTime get _primerDia =>
      DateTime(widget.resumen.anio, widget.resumen.mes, 1);

  /// Último día del mes del resumen (límite superior del picker)
  DateTime get _ultimoDia =>
      DateTime(widget.resumen.anio, widget.resumen.mes + 1, 0);

  // ── Date pickers ──────────────────────────────────────────────────────────

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

  Future<void> _pickFechaUnica() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaUnica ?? _primerDia,
      firstDate: _primerDia,
      lastDate: _ultimoDia,
      builder: _datePickerTheme,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _filtroActivo = _FiltroDetalle.fechaUnica;
      _fechaUnica = picked;
      _rango = null;
    });
    _cargarConFiltro();
  }

  Future<void> _pickRango() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: _primerDia,
      lastDate: _ultimoDia,
      initialDateRange: _rango ?? DateTimeRange(start: _primerDia, end: _ultimoDia),
      builder: _datePickerTheme,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _filtroActivo = _FiltroDetalle.rango;
      _rango = picked;
      _fechaUnica = null;
    });
    _cargarConFiltro();
  }

  // ── Carga de datos ────────────────────────────────────────────────────────

  Future<void> _cargarConFiltro() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(ingresoRepositoryProvider);
      final List<Ingreso> result;

      if (_filtroActivo == _FiltroDetalle.fechaUnica && _fechaUnica != null) {
        result = await repo.getIngresosPorFecha(fecha: _fechaUnica!);
      } else if (_filtroActivo == _FiltroDetalle.rango && _rango != null) {
        result = await repo.getIngresosPorPeriodo(
          desde: _rango!.start,
          hasta: _rango!.end,
        );
      } else {
        result = List.from(widget.resumen.ingresos);
      }

      if (mounted) setState(() => _ingresos = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al filtrar: $e'),
            backgroundColor: AppColors.errorContainer,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _limpiarFiltro() {
    setState(() {
      _filtroActivo = null;
      _fechaUnica = null;
      _rango = null;
      _ingresos = List.from(widget.resumen.ingresos);
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainer,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/ingresos'),
        ),
        title: Text(
          'Detalle de Ingresos — ${widget.resumen.titulo}',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: ElevatedButton.icon(
              onPressed: () {
                /* TODO: abrir form */
              },
              icon: const Icon(Icons.add, size: 16),
              label: Text('Agregar Ingreso', style: AppTextStyles.buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(AppRadius.md),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // — Título —
                  Text('Filtrar por', style: AppTextStyles.labelCaps),
                  const SizedBox(height: AppSpacing.xs),
                  // — Filtros (auto-aplican al seleccionar) —
                  IngresoFiltros(
                    fechaUnicaLabel: _fechaUnicaLabel,
                    rangoLabel: _rangoLabel,
                    hayFiltroActivo: _hayFiltro,
                    filtroDescripcion: _hayFiltro ? _filtroDescripcion : null,
                    onTapFechaUnica: _pickFechaUnica,
                    onTapRango: _pickRango,
                    onLimpiar: _hayFiltro ? _limpiarFiltro : null,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // — Tarjetas de totales —
                  Row(
                    children: [
                      Expanded(
                        child: TotalCard(
                          titulo: 'Total Efectivo',
                          monto: _totalEfectivo,
                          icon: Icons.payments,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TotalCard(
                          titulo: 'Total Transferencia',
                          monto: _totalTransferencia,
                          icon: Icons.credit_card,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // — Tabla —
                  IngresoTable(ingresos: _ingresos),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /* TODO: abrir form */
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
