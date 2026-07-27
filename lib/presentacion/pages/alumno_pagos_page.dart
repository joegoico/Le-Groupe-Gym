import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/delete_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/forms/pago_form.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/presentacion/pages/detalle_widgets/estado_cuenta_card.dart';
import 'package:le_groupe_gym/presentacion/pages/detalle_widgets/historial_pagos_card.dart';
import 'package:le_groupe_gym/providers/alumno_view_providers.dart';

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

class AlumnoPagosPage extends ConsumerStatefulWidget {
  final Alumno alumno;

  const AlumnoPagosPage({super.key, required this.alumno});

  @override
  ConsumerState<AlumnoPagosPage> createState() => _AlumnoPagosPageState();
}

class _AlumnoPagosPageState extends ConsumerState<AlumnoPagosPage> {
  bool _isLoading = true;
  List<Pago> _pagos = [];
  Pago? _ultimoPago;

  int? _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _loadData();
  }

  Future<void> _loadData() async {
    debugPrint(
      'AlumnoPagosPage: ${widget.alumno.nombre} + ${widget.alumno.apellido}',
    );
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final pagoRepo = ref.read(pagoRepositoryProvider);
      final results = await Future.wait([
        pagoRepo.getUltimoPago(widget.alumno.idAlumno),
        pagoRepo.getPagosPorAlumno(
          widget.alumno.idAlumno,
          anio: _selectedYear,
          mes: _selectedMonth,
        ),
      ]);

      if (mounted) {
        setState(() {
          _ultimoPago = results[0] as Pago?;
          _pagos = results[1] as List<Pago>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pagos: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  String _getInitials() {
    final n = widget.alumno.nombre.isNotEmpty
        ? widget.alumno.nombre[0].toUpperCase()
        : '';
    final a = widget.alumno.apellido.isNotEmpty
        ? widget.alumno.apellido[0].toUpperCase()
        : '';
    return '$n$a';
  }

  void _editarPago(Pago pago) {
    showDialog(
      context: context,
      builder: (ctx) => PagoForm(
        alumno: widget.alumno,
        pagoAEditar: pago,
      ),
    ).then((_) {
      _loadData();
    });
  }

  Future<void> _confirmarEliminarPago(Pago pago) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteConfirmDialog(
        title: 'Eliminar pago',
        message: '¿Estás seguro de que deseás eliminar este pago? Esta acción no se puede deshacer.',
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(pagoRepositoryProvider).deletePago(pago.idPago);
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar pago: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColor(widget.alumno.nombre);
    final deudorAsync = ref.watch(deudorAlumnoProvider(widget.alumno.idAlumno));
    final deudor = deudorAsync.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          key: const Key('pagos_back_btn'),
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(
          'Pagos de Alumno',
          style: AppTextStyles.titleMd.copyWith(
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Cabecera (Avatar y Nombre) ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: avatarColor,
                      child: Text(
                        _getInitials(),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        widget.alumno.nombreCompleto,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Estado de Cuenta ──────────────────────────────────────────
                EstadoCuentaCard(
                  ultimoPago: _ultimoPago,
                  deudor: deudor,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Historial de Pagos ──────────────────────────────────────────
                HistorialPagosCard(
                  pagos: _pagos,
                  isLoading: _isLoading,
                  alumno: widget.alumno,
                  onEdit: _editarPago,
                  onDelete: _confirmarEliminarPago,
                  onFilterSelected: (val) {
                    if (val == 'todos') {
                      setState(() {
                        _selectedMonth = null;
                        _selectedYear = DateTime.now().year;
                      });
                      _loadData();
                    } else if (val.startsWith('mes_')) {
                      setState(() {
                        _selectedMonth = int.parse(val.split('_')[1]);
                      });
                      _loadData();
                    }
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Botón Registrar Pago ──────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    key: const Key('pagos_registrar_pago_btn'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => PagoForm(alumno: widget.alumno),
                      ).then((_) {
                        _loadData();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      'Registrar Pago',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
