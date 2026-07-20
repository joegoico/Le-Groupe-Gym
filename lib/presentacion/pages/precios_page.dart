import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/top_bar.dart';
import 'package:le_groupe_gym/presentacion/forms/precio_form.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';
import 'package:le_groupe_gym/presentacion/pages/precios_widgets/descuentos_panel.dart';
import 'package:le_groupe_gym/presentacion/pages/precios_widgets/precio_card.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:le_groupe_gym/presentacion/builder/sidebar.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:go_router/go_router.dart';

class PreciosPage extends ConsumerStatefulWidget {
  const PreciosPage({super.key});

  @override
  ConsumerState<PreciosPage> createState() => _PreciosPageState();
}

class _PreciosPageState extends ConsumerState<PreciosPage> {
  bool _isLoading = true;
  bool _sidebarCollapsed = false;
  List<Precio> _precios = [];
  List<Descuento> _descuentos = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final precioRepo = ref.read(precioRepositoryProvider);
      final descuentoRepo = ref.read(descuentoRepositoryProvider);

      final results = await Future.wait([
        precioRepo.getPrecios(),
        descuentoRepo.getDescuentos(),
      ]);

      if (mounted) {
        setState(() {
          _precios = results[0] as List<Precio>;
          _descuentos = results[1] as List<Descuento>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAgregarPrecio() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: PrecioForm(
          precioRepository: ref.read(precioRepositoryProvider),
          onGuardar: (_) {
            _loadData();
            Navigator.of(dialogContext).pop();
          },
          onCancelar: () => Navigator.of(dialogContext).pop(),
        ),
      ),
    );
  }

  Future<void> _editarPrecio(Precio precio) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: PrecioForm(
          precio: precio,
          precioRepository: ref.read(precioRepositoryProvider),
          onGuardar: (_) {
            _loadData();
            Navigator.of(dialogContext).pop();
          },
          onCancelar: () => Navigator.of(dialogContext).pop(),
        ),
      ),
    );
  }

  Future<void> _eliminarPrecio(Precio precio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: Text('Eliminar plan', style: AppTextStyles.titleMd),
        content: Text(
          '¿Seguro que querés eliminar el plan de ${precio.cantidadDias} días? Esta acción no se puede deshacer.',
          style: AppTextStyles.labelCaps,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancelar', style: AppTextStyles.labelCaps),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    try {
      await ref.read(precioRepositoryProvider).deletePrecio(precio.idPrecio!);
      if (mounted) {
        setState(
          () => _precios.removeWhere((p) => p.idPrecio == precio.idPrecio),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Sidebar(
            currentRoute: '/precios',
            isCollapsed: _sidebarCollapsed,
            onCerrarSesion: () async {
              await SupabaseConfig.client.auth.signOut();
              if (mounted) context.go('/login');
            },
            onNavigate: (route) => context.go(route),
          ),
          Expanded(
            child: Column(
              children: [
                // TopBar
                TopBar(
                  onMenuPressed: () =>
                      setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                  pageTitle: 'Planes y Tarifas',
                  actionsEnd: [
                    ElevatedButton.icon(
                      onPressed: _handleAgregarPrecio,
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        'Nuevo Plan',
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
                // Contenido
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel de precios
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Planes de Suscripción', style: AppTextStyles.titleMd),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: _precios
                      .map(
                        (precio) => PrecioCard(
                          precio: precio,
                          onEditar: _editarPrecio,
                          onEliminar: _eliminarPrecio,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),

        // Panel de descuentos
        SizedBox(
          width: 280,
          child: DescuentosPanel(
            descuentos: _descuentos,
            onAgregarDescuento: () {},
            onEliminarDescuento: (_) {},
          ),
        ),
      ],
    );
  }
}
