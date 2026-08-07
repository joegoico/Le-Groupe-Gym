import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/core/global_messenger.dart';

import 'package:le_groupe_gym/presentacion/builder/widgets/top_bar.dart';
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cargar pagos: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 10),
              ),
            );
          }
        });
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

  Future<void> _editarPago(Pago pago) async {
    final nuevoPago = await showDialog<Pago>(
      context: context,
      builder: (ctx) => PagoForm(alumno: widget.alumno, pagoAEditar: pago),
    );
    if (nuevoPago != null) {
      _onPagoGuardado(nuevoPago, esEdicion: true);
    }
  }

  Future<void> _crearPago() async {
    final nuevoPago = await showDialog<Pago>(
      context: context,
      builder: (ctx) => PagoForm(alumno: widget.alumno),
    );
    if (nuevoPago != null) {
      _onPagoGuardado(nuevoPago, esEdicion: false);
    }
  }

  void _onPagoGuardado(Pago pago, {required bool esEdicion}) {
    setState(() {
      if (esEdicion) {
        final idx = _pagos.indexWhere((p) => p.idPago == pago.idPago);
        if (idx != -1) _pagos[idx] = pago;
        if (_ultimoPago?.idPago == pago.idPago) {
          _ultimoPago = pago;
        }
      } else {
        _pagos.insert(0, pago);
        _pagos.sort((a, b) => b.fechaDePago.compareTo(a.fechaDePago));
        _ultimoPago = _pagos.first;
      }
    });

    GlobalMessenger.showSuccessSnackbar(
      esEdicion ? 'Pago actualizado' : 'Pago registrado',
    );
    ref.invalidate(deudorAlumnoProvider(widget.alumno.idAlumno));
  }

  Future<void> _confirmarEliminarPago(Pago pago) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteConfirmDialog(
        title: 'Eliminar pago',
        message:
            '¿Estás seguro de que deseás eliminar este pago? Esta acción no se puede deshacer.',
      ),
    );

    if (confirmed != true) return;

    final previousPagos = List<Pago>.from(_pagos);
    final previousUltimoPago = _ultimoPago;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final pagoRepository = ref.read(pagoRepositoryProvider);
      await pagoRepository.deletePago(pago.idPago);

      final pagosActualizados = previousPagos
          .where((item) => item.idPago != pago.idPago)
          .toList();
      final borrabaUltimoPago = previousUltimoPago?.idPago == pago.idPago;

      if (mounted) {
        setState(() {
          _pagos = pagosActualizados;
          _ultimoPago = borrabaUltimoPago
              ? (pagosActualizados.isNotEmpty ? pagosActualizados.first : null)
              : previousUltimoPago;
        });
      }

      if (borrabaUltimoPago) {
        pagoRepository
            .getUltimoPago(widget.alumno.idAlumno)
            .then((ultimoPago) {
              if (!mounted) return;
              setState(() => _ultimoPago = ultimoPago);
            })
            .catchError((_) {
              // Conservamos el estado local si el refresco del resumen falla.
            });
      }

      ref.invalidate(deudorAlumnoProvider(widget.alumno.idAlumno));
      GlobalMessenger.showSuccessSnackbar('Pago eliminado');
    } catch (e) {
      if (mounted) {
        setState(() {
          _pagos = previousPagos;
          _ultimoPago = previousUltimoPago;
        });
      }
      GlobalMessenger.showErrorSnackbar(
        'Ocurrió un error inesperado al eliminar el pago. Verifica tu conexión e intenta de nuevo.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              pageTitle: 'Pagos de Alumno',
              isBack: true,
              menuBtnKey: const Key('pagos_back_btn'),
              onMenuPressed: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
            ),
            Expanded(
              child: Center(
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
                            onPressed: _crearPago,
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
            ),
          ],
        ),
      ),
    );
  }
}
