import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';
import 'package:le_groupe_gym/data/repositories/precio_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/inline_error.dart';

class PrecioForm extends StatefulWidget {
  final Precio? precio;
  final PrecioRepository precioRepository;
  final ValueChanged<Precio> onGuardar;
  final VoidCallback onCancelar;

  const PrecioForm({
    super.key,
    this.precio,
    required this.precioRepository,
    required this.onGuardar,
    required this.onCancelar,
  });

  @override
  State<PrecioForm> createState() => _PrecioFormState();
}

class _PrecioFormState extends State<PrecioForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _precioController;
  late TextEditingController _cantidadDiasController;
  String? _errorPrecio;

  @override
  void initState() {
    super.initState();
    _precioController = TextEditingController(
      text: widget.precio?.valor.toString() ?? '',
    );
    _cantidadDiasController = TextEditingController(
      text: widget.precio?.cantidadDias.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _precioController.dispose();
    _cantidadDiasController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _errorPrecio = null);

    final strValor = _precioController.text.trim();
    final strDias = _cantidadDiasController.text.trim();

    if (strValor.isEmpty || strDias.isEmpty) {
      return; // El validator de TextFormField ya muestra que es requerido
    }

    final nuevoValor = int.tryParse(strValor);
    final nuevaCantidadDias = int.tryParse(strDias);

    if (nuevoValor == null || nuevaCantidadDias == null) {
      return; // El validator de TextFormField ya muestra que no es numérico
    }

    if (nuevoValor <= 0) {
      setState(() => _errorPrecio = 'El valor debe ser mayor a 0');
      return;
    }

    if (nuevaCantidadDias <= 0 || nuevaCantidadDias >= 8) {
      setState(
        () => _errorPrecio = 'La cantidad de días debe estar entre 1 y 7',
      );
      return;
    }

    try {
      final preciosExistentes = await widget.precioRepository.getPrecios();
      final yaExiste = preciosExistentes.any(
        (p) =>
            p.cantidadDias == nuevaCantidadDias &&
            p.idPrecio != widget.precio?.idPrecio,
      );

      if (yaExiste) {
        setState(() {
          _errorPrecio = 'Ya existe un plan con esta duración.';
        });
        return;
      }
    } catch (e) {
      // Si falla la obtención, procedemos para que falle en guardar y se muestre ahí
    }

    final precio = Precio(
      idPrecio: widget.precio?.idPrecio ?? const Uuid().v4(),
      valor: nuevoValor,
      cantidadDias: nuevaCantidadDias,
    );

    widget.onGuardar(precio);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 480,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.all(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HEADER ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: AppRadius.md),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.onSurface.withValues(alpha: 0.10),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.all(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.monetization_on_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.precio == null
                        ? 'Registrar Nuevo Plan'
                        : 'Editar Plan',
                    style: AppTextStyles.titleMd.copyWith(fontSize: 15),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onCancelar,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.onSurfaceVariant,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          // ── BODY ────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _FieldLabel('Valor del plan', icon: Icons.attach_money),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    height: 44,
                    child: TextFormField(
                      controller: _precioController,
                      style: AppTextStyles.subtittles.copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ej. 18000',
                        hintStyle: AppTextStyles.subtittles.copyWith(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainer,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 10,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(AppRadius.md),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(AppRadius.md),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El precio es requerido';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Debe ser un número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  const _FieldLabel(
                    'Duración (días)',
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    height: 44,
                    child: TextFormField(
                      controller: _cantidadDiasController,
                      style: AppTextStyles.subtittles.copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ej. 3',
                        hintStyle: AppTextStyles.subtittles.copyWith(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainer,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 10,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(AppRadius.md),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(AppRadius.md),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La cantidad de días es requerida';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Debe ser un número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  if (_errorPrecio != null) ...[
                    InlineError(
                      key: const Key('error-precio-existente'),
                      mensaje: _errorPrecio!,
                      icon: Icons.warning_amber_rounded,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: widget.onCancelar,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.onSurfaceVariant,
                              side: const BorderSide(
                                color: AppColors.outlineVariant,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(AppRadius.md),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.check, size: 16),
                            label: Text(
                              widget.precio == null ? 'Crear Plan' : 'Guardar',
                              style: AppTextStyles.buttonText.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              disabledBackgroundColor:
                                  AppColors.surfaceContainerHigh,
                              disabledForegroundColor:
                                  AppColors.onSurfaceVariant,
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(AppRadius.md),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label de sección con acento izquierdo en lime primario.
class _FieldLabel extends StatelessWidget {
  final String text;
  final IconData? icon;

  const _FieldLabel(this.text, {this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(AppRadius.full),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppColors.onSurface),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: AppTextStyles.subtittlesBold.copyWith(
            fontSize: 13,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
