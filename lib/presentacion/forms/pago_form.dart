import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/pago_model.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';

final planesProvider = FutureProvider.autoDispose<List<Precio>>((ref) async {
  return ref.read(precioRepositoryProvider).getPrecios();
});

class PagoForm extends ConsumerStatefulWidget {
  final Alumno alumno;

  const PagoForm({super.key, required this.alumno});

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

  @override
  void dispose() {
    _montoController.dispose();
    _comentariosController.dispose();
    _diasController.dispose();
    super.dispose();
  }

  Future<void> _guardarPago() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final monto = double.parse(_montoController.text);
      final dias = int.parse(_diasController.text);

      final nuevoPago = Pago(
        idPago: '', // Supabase generará el UUID automáticamente
        idAlumno: widget.alumno.idAlumno,
        fechaDePago: _fechaPago,
        monto: monto,
        medioDePago: _medioPago,
        comentarios: _comentariosController.text.isNotEmpty
            ? _comentariosController.text
            : null,
        cantidadDias: dias,
      );

      await ref.read(pagoRepositoryProvider).insertarPago(nuevoPago);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planesAsync = ref.watch(planesProvider);

    return AlertDialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.lg),
      ),
      title: Text(
        'Registrar Pago',
        style: GoogleFonts.inter(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alumno: ${widget.alumno.nombreCompleto}',
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Selector de Plan
                Text(
                  'Plan',
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                planesAsync.when(
                  data: (planes) {
                    return DropdownButtonFormField<Precio?>(
                      initialValue: _planSeleccionado,
                      dropdownColor: AppColors.surfaceContainerHigh,
                      style: GoogleFonts.inter(color: AppColors.onSurface),
                      decoration: _buildInputDecoration(),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            'Pago Personalizado',
                            style: GoogleFonts.inter(),
                          ),
                        ),
                        ...planes.map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              '${p.cantidadDias} días - \$${p.valor.toInt()}',
                              style: GoogleFonts.inter(),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _planSeleccionado = val;
                          if (val != null) {
                            _montoController.text = val.valor.toString();
                            _diasController.text = val.cantidadDias.toString();
                          } else {
                            _montoController.clear();
                            _diasController.clear();
                          }
                        });
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text(
                    'Error: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Monto
                Text(
                  'Monto',
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _montoController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(color: AppColors.onSurface),
                  decoration: _buildInputDecoration(prefixText: '\$ '),
                  enabled: _planSeleccionado == null,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'El monto es obligatorio';
                    if (double.tryParse(val) == null) return 'Monto inválido';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Medio de Pago
                Text(
                  'Medio de Pago',
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  initialValue: _medioPago,
                  dropdownColor: AppColors.surfaceContainerHigh,
                  style: GoogleFonts.inter(color: AppColors.onSurface),
                  decoration: _buildInputDecoration(),
                  items: const [
                    DropdownMenuItem(
                      value: 'Efectivo',
                      child: Text('Efectivo'),
                    ),
                    DropdownMenuItem(
                      value: 'Transferencia',
                      child: Text('Transferencia'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _medioPago = val);
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Cantidad de Días
                Text(
                  'Cantidad de días',
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  key: const Key('pago_dias_input'),
                  controller: _diasController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(color: AppColors.onSurface),
                  decoration: _buildInputDecoration(),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Requerido';
                    final num = int.tryParse(val);
                    if (num == null || num < 1 || num > 7) return 'Entre 1 y 7';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Comentarios
                Text(
                  'Comentarios',
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _comentariosController,
                  style: GoogleFonts.inter(color: AppColors.onSurface),
                  decoration: _buildInputDecoration(),
                  maxLines: 2,
                  validator: (val) {
                    if (_planSeleccionado == null &&
                        (val == null || val.isEmpty)) {
                      return 'El comentario es obligatorio para pagos personalizados';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: GoogleFonts.inter(color: AppColors.primary),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _guardarPago,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(AppRadius.md),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Guardar Pago',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({String? prefixText}) {
    return InputDecoration(
      prefixText: prefixText,
      prefixStyle: GoogleFonts.inter(color: AppColors.onSurface),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }
}
