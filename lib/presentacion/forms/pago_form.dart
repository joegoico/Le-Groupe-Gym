import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:le_groupe_gym/presentacion/forms/alumno_forms_widgets/descuento_switch.dart';

final planesProvider = FutureProvider.autoDispose<List<Precio>>((ref) async {
  return ref.read(precioRepositoryProvider).getPrecios();
});

final descuentosProvider = FutureProvider.autoDispose<List<Descuento>>((ref) async {
  return ref.read(descuentoRepositoryProvider).getDescuentos();
});

class PagoForm extends ConsumerStatefulWidget {
  final Alumno alumno;
  final Pago? pagoAEditar;

  const PagoForm({super.key, required this.alumno, this.pagoAEditar});

  @override
  ConsumerState<PagoForm> createState() => _PagoFormState();
}

class _PagoFormState extends ConsumerState<PagoForm> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _comentariosController = TextEditingController();
  final _diasController = TextEditingController();

  Precio? _planSeleccionado;
  String _medioPago = 'Efectivo';
  DateTime _fechaPago = DateTime.now();
  bool _isLoading = false;
  bool _aplicaDescuento = false;

  /// Error inline debajo del campo Comentarios (pago personalizado sin comentario)
  String? _errorComentario;
  /// Error inline debajo del selector de fecha (pago duplicado en el mes)
  String? _errorFecha;
  /// Error inline del servidor genérico (red, BD, etc.) mostrado antes del botón
  String? _errorServidor;

  @override
  void initState() {
    super.initState();
    if (widget.pagoAEditar != null) {
      _montoController.text = (widget.pagoAEditar!.monto % 1 == 0)
          ? widget.pagoAEditar!.monto.toInt().toString()
          : widget.pagoAEditar!.monto.toString();
      _comentariosController.text = widget.pagoAEditar!.comentarios ?? '';
      _diasController.text = widget.pagoAEditar!.cantidadDias.toString();
      _medioPago = widget.pagoAEditar!.medioDePago;
      _fechaPago = widget.pagoAEditar!.fechaDePago;
      _aplicaDescuento = widget.pagoAEditar!.aplicaDescuento;
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _comentariosController.dispose();
    _diasController.dispose();
    super.dispose();
  }

  Future<void> _guardarPago() async {
    // Limpiar errores previos
    setState(() {
      _errorComentario = null;
      _errorFecha = null;
      _errorServidor = null;
    });

    // Validar comentario obligatorio para pagos personalizados
    if (_planSeleccionado == null &&
        widget.pagoAEditar == null &&
        _comentariosController.text.trim().isEmpty) {
      setState(() {
        _errorComentario = 'El comentario es obligatorio para pagos personalizados.';
      });
      return;
    }

    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      final monto = double.parse(_montoController.text);
      final dias = int.parse(_diasController.text);

      final nuevoPago = Pago(
        idPago:
            widget.pagoAEditar?.idPago ??
            '', // Supabase generará el UUID automáticamente al crear
        idAlumno: widget.alumno.idAlumno,
        fechaDePago: _fechaPago,
        monto: monto,
        medioDePago: _medioPago,
        comentarios: _comentariosController.text.isNotEmpty
            ? _comentariosController.text
            : null,
        cantidadDias: dias,
        aplicaDescuento: _aplicaDescuento,
      );

      if (widget.pagoAEditar == null) {
        await ref.read(pagoRepositoryProvider).insertarPago(nuevoPago);
      } else {
        await ref.read(pagoRepositoryProvider).updatePago(nuevoPago);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString();
        // Detectar error de unicidad de Supabase / Postgres
        final esUnicidad = msg.contains('unique') ||
            msg.contains('duplicate') ||
            msg.contains('23505') ||
            msg.contains('already exists');
        setState(() {
          if (esUnicidad) {
            _errorFecha =
                'Este alumno ya tiene un pago registrado para ese mes. '
                'Solo se permite un pago por alumno por mes.';
          } else {
            _errorServidor = 'Ocurrió un error al guardar: $msg';
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          color: AppColors.onSurfaceVariant,
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planesAsync = ref.watch(planesProvider);
    final descuentosAsync = ref.watch(descuentosProvider);

    return AlertDialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.lg),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.pagoAEditar != null ? 'Editar Pago' : 'Registrar Pago',
            style: GoogleFonts.inter(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.alumno.nombreCompleto,
                      style: GoogleFonts.inter(
                        color: AppColors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Monto a Cobrar (Display de Gran Tamaño)
                _buildSectionTitle('Monto a Cobrar'),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '\$',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _montoController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.white24),
                          ),
                          enabled: _planSeleccionado == null,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Requerido';
                            if (double.tryParse(val) == null) return 'Inválido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Fecha de Pago
                _buildSectionTitle('Fecha de Pago'),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _fechaPago,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _fechaPago = date;
                        _errorFecha = null; // limpiar al cambiar la fecha
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${DateFormat('E, d MMMM yyyy', 'es').format(_fechaPago)}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Error inline de fecha duplicada
                if (_errorFecha != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _InlineError(
                      key: const Key('error-fecha-duplicada'),
                      mensaje: _errorFecha!,
                      icon: Icons.event_busy,
                    ),
                  ),

                // Concepto / Plan
                _buildSectionTitle('Concepto / Plan'),
                planesAsync.when(
                  data: (planes) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(
                            'Personalizado',
                            style: TextStyle(
                              color: _planSeleccionado == null
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: _planSeleccionado == null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: _planSeleccionado == null,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _planSeleccionado = null;
                                if (widget.pagoAEditar != null) {
                                  _montoController.text =
                                      (widget.pagoAEditar!.monto % 1 == 0)
                                      ? widget.pagoAEditar!.monto
                                            .toInt()
                                            .toString()
                                      : widget.pagoAEditar!.monto.toString();
                                  _diasController.text = widget
                                      .pagoAEditar!
                                      .cantidadDias
                                      .toString();
                                } else {
                                  _montoController.clear();
                                  _diasController.clear();
                                }
                              });
                            }
                          },
                        ),
                        ...planes.map((p) {
                          final isSelected =
                              _planSeleccionado?.idPrecio == p.idPrecio;
                          return ChoiceChip(
                            label: Text(
                              '${p.cantidadDias} días',
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _planSeleccionado = p;
                                  
                                  double baseMonto = p.valor.toDouble();
                                  if (_aplicaDescuento && descuentosAsync.value != null && descuentosAsync.value!.isNotEmpty) {
                                    final descValue = descuentosAsync.value!.first.valor;
                                    baseMonto = baseMonto - descValue.toDouble();
                                    if (baseMonto < 0.0) baseMonto = 0.0;
                                  }
                                  
                                  _montoController.text = (baseMonto % 1 == 0)
                                      ? baseMonto.toInt().toString()
                                      : baseMonto.toString();
                                  _diasController.text = p.cantidadDias
                                      .toString();
                                });
                              }
                            },
                          );
                        }),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text(
                    'Error: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

                // Cantidad de Días (solo visible si es personalizado y estamos editando/creando)
                if (_planSeleccionado == null) ...[
                  _buildSectionTitle('Cantidad de días'),
                  TextFormField(
                    controller: _diasController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF141414),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Ej: 30',
                      hintStyle: const TextStyle(color: Colors.white24),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Requerido';
                      if (int.tryParse(val) == null) return 'Número inválido';
                      return null;
                    },
                  ),
                ],

                // Método de Pago
                _buildSectionTitle('Método de Pago'),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'Efectivo',
                      label: Text('Efectivo'),
                      icon: Icon(Icons.money),
                    ),
                    ButtonSegment(
                      value: 'Transferencia',
                      label: Text('Transferencia'),
                      icon: Icon(Icons.account_balance),
                    ),
                    ButtonSegment(
                      value: 'Combinado',
                      label: Text('Combinado'),
                      icon: Icon(Icons.credit_card),
                    ),
                  ],
                  selected: {_medioPago},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _medioPago = newSelection.first;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primary;
                      }
                      return AppColors.surfaceContainerHigh;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.black;
                      }
                      return Colors.white;
                    }),
                  ),
                ),
                
                // Descuento
                _buildSectionTitle('Descuento'),
                DescuentoSwitch(
                  value: _aplicaDescuento,
                  onChanged: (v) {
                    setState(() {
                      _aplicaDescuento = v;
                      if (_planSeleccionado != null && descuentosAsync.value != null && descuentosAsync.value!.isNotEmpty) {
                        double baseMonto = _planSeleccionado!.valor.toDouble();
                        if (_aplicaDescuento) {
                          final descValue = descuentosAsync.value!.first.valor;
                          baseMonto = baseMonto - descValue.toDouble();
                          if (baseMonto < 0.0) baseMonto = 0.0;
                        }
                        _montoController.text = (baseMonto % 1 == 0)
                            ? baseMonto.toInt().toString()
                            : baseMonto.toString();
                      }
                    });
                  },
                ),

                // Comentarios
                _buildSectionTitle(
                  _planSeleccionado == null
                      ? 'Comentarios (Obligatorio para personalizado)'
                      : 'Comentarios (Opcional)',
                ),
                TextFormField(
                  controller: _comentariosController,
                  maxLines: 2,
                  style: GoogleFonts.inter(color: AppColors.onSurface),
                  onChanged: (_) {
                    // Limpia el error inline al editar
                    if (_errorComentario != null) {
                      setState(() => _errorComentario = null);
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF141414),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: _errorComentario != null
                          ? const BorderSide(color: Colors.redAccent, width: 1.5)
                          : BorderSide.none,
                    ),
                    hintText: 'Nota para el pago...',
                    hintStyle: const TextStyle(color: Colors.white24),
                  ),
                ),
                // Error inline comentario
                if (_errorComentario != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _InlineError(mensaje: _errorComentario!),
                  ),

                // Error del servidor (unicidad, etc.)
                if (_errorServidor != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _InlineError(
                      key: const Key('error-servidor-generico'),
                      mensaje: _errorServidor!,
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _guardarPago,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle),
          label: Text(
            widget.pagoAEditar != null ? 'Guardar Cambios' : 'Confirmar Pago',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Banner de error inline para mostrar dentro del formulario.
class _InlineError extends StatelessWidget {
  final String mensaje;
  final IconData icon;

  const _InlineError({
    super.key,
    required this.mensaje,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
