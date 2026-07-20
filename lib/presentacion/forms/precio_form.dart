import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';
import 'package:le_groupe_gym/data/repositories/precio_repository.dart';

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
  bool _isLoading = false;

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
    setState(() => _isLoading = true);
    try {
      final precio = Precio(
        idPrecio: widget.precio?.idPrecio,
        valor: int.parse(_precioController.text.trim()),
        cantidadDias: int.parse(_cantidadDiasController.text.trim()),
      );
      if (widget.precio != null) {
        await widget.precioRepository.updatePrecio(precio);
      } else {
        await widget.precioRepository.createPrecio(precio);
      }
      widget.onGuardar(precio);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.precio == null ? 'Nuevo Precio' : 'Editar Precio',
              style: AppTextStyles.titleMd,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _precioController,
              decoration: const InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffixIcon: Icon(Icons.money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El precio es requerido';
                }
                final valorInt = int.tryParse(value.trim());
                if (valorInt == null) {
                  return 'El precio debe ser un número válido';
                }
                if (valorInt <= 0) {
                  return 'El precio debe ser mayor a 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cantidadDiasController,
              decoration: const InputDecoration(
                labelText: 'Cantidad de Días',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.calendar_month_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La cantidad de días es requerida';
                }
                final dias = int.tryParse(value);
                if (dias == null || dias <= 0) {
                  return 'La cantidad de días debe ser mayor a 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onCancelar,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                      ),
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
