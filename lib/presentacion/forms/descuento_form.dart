import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';

class DescuentoForm extends StatefulWidget {
  final Descuento? descuento;
  final Function(Descuento) onGuardar;
  final VoidCallback onCancelar;

  const DescuentoForm({
    super.key,
    this.descuento,
    required this.onGuardar,
    required this.onCancelar,
  });

  @override
  State<DescuentoForm> createState() => _DescuentoFormState();
}

class _DescuentoFormState extends State<DescuentoForm> {
  final TextEditingController _valorController = TextEditingController();

  bool get _canSave =>
      _valorController.text.isNotEmpty &&
      int.tryParse(_valorController.text) != null;

  @override
  void initState() {
    super.initState();
    if (widget.descuento != null) {
      _valorController.text = widget.descuento!.valor.toString();
    }
    _valorController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            widget.descuento != null ? 'Editar Descuento' : 'Nuevo Descuento',
            style: AppTextStyles.labelCaps,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Campo valor
          Text('VALOR (\$)', style: AppTextStyles.titleCards),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const Key('descuento_valor_field'),
            controller: _valorController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.titleMd,
            decoration: InputDecoration(
              hintText: 'Ej. 1500',
              hintStyle: AppTextStyles.titleMd,
              suffixIcon: const Icon(Icons.attach_money),
              suffixStyle: AppTextStyles.titleMd,
              filled: true,
              fillColor: AppColors.surfaceContainer,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(AppRadius.md),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Botones
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: widget.onCancelar, child: Text('Cancelar')),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: _canSave
                    ? () => widget.onGuardar(
                        Descuento(
                          id: widget.descuento?.id,
                          valor: int.parse(_valorController.text),
                        ),
                      )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: AppColors.surfaceContainerHigh,
                  disabledForegroundColor: AppColors.onSurfaceVariant,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Guardar',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
