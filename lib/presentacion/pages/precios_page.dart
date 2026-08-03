import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/core/global_messenger.dart';
import 'package:le_groupe_gym/services/auth_service.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/delete_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/logout_confirm_dialog.dart';
import 'package:le_groupe_gym/presentacion/builder/widgets/top_bar.dart';
import 'package:le_groupe_gym/presentacion/forms/precio_form.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';
import 'package:le_groupe_gym/presentacion/pages/precios_widgets/descuentos_panel.dart';
import 'package:le_groupe_gym/presentacion/pages/precios_widgets/precio_card.dart';
import 'package:le_groupe_gym/providers/repository_providers.dart';
import 'package:le_groupe_gym/presentacion/builder/sidebar.dart';
import 'package:le_groupe_gym/presentacion/forms/descuento_form.dart';

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: PrecioForm(
          precioRepository: ref.read(precioRepositoryProvider),
          onGuardar: (precio) {
            Navigator.of(dialogContext).pop();
            _onPrecioGuardado(precio, esEdicion: false);
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: PrecioForm(
          precio: precio,
          precioRepository: ref.read(precioRepositoryProvider),
          onGuardar: (p) {
            Navigator.of(dialogContext).pop();
            _onPrecioGuardado(p, esEdicion: true);
          },
          onCancelar: () => Navigator.of(dialogContext).pop(),
        ),
      ),
    );
  }

  void _onPrecioGuardado(Precio precio, {required bool esEdicion}) {
    final previousPrecios = List<Precio>.from(_precios);

    setState(() {
      if (esEdicion) {
        final idx = _precios.indexWhere((p) => p.idPrecio == precio.idPrecio);
        if (idx != -1) _precios[idx] = precio;
      } else {
        _precios.add(precio);
      }
    });

    _guardarPrecioEnBackground(precio, esEdicion, previousPrecios);
  }

  Future<void> _guardarPrecioEnBackground(Precio precio, bool esEdicion, List<Precio> previousPrecios) async {
    try {
      if (esEdicion) {
        await ref.read(precioRepositoryProvider).updatePrecio(precio);
      } else {
        await ref.read(precioRepositoryProvider).createPrecio(precio);
      }
      GlobalMessenger.showSuccessSnackbar(esEdicion ? 'Plan actualizado' : 'Plan creado');
    } catch (e) {
      if (mounted) setState(() => _precios = previousPrecios);
      GlobalMessenger.showErrorSnackbar('Ocurrió un error inesperado al guardar el plan. Verifica tu conexión e intenta de nuevo.');
    }
  }

  Future<void> _eliminarPrecio(Precio precio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmDialog(
        title: 'Eliminar plan',
        message: '¿Seguro que querés eliminar el plan de ${precio.cantidadDias} días? Esta acción no se puede deshacer.',
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
      GlobalMessenger.showSuccessSnackbar('Plan eliminado');
    } catch (e) {
      GlobalMessenger.showErrorSnackbar('Ocurrió un error inesperado al eliminar el plan. Verifica tu conexión e intenta de nuevo.');
    }
  }

  void _mostrarFormDescuento(BuildContext context, {Descuento? descuento}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 400,
          child: DescuentoForm(
            descuento: descuento,
            onCancelar: () => Navigator.pop(context),
            onGuardar: (d) {
              Navigator.pop(context);
              _guardarDescuento(d, esEdicion: descuento != null);
            },
          ),
        ),
      ),
    );
  }

  void _guardarDescuento(Descuento descuento, {required bool esEdicion}) {
    final previousDescuentos = List<Descuento>.from(_descuentos);
    
    setState(() {
      if (esEdicion) {
        final index = _descuentos.indexWhere((d) => d.id == descuento.id);
        if (index != -1) _descuentos[index] = descuento;
      } else {
        _descuentos.add(descuento);
      }
    });

    _guardarDescuentoEnBackground(descuento, esEdicion, previousDescuentos);
  }

  Future<void> _guardarDescuentoEnBackground(Descuento descuento, bool esEdicion, List<Descuento> previousDescuentos) async {
    try {
      final repo = ref.read(descuentoRepositoryProvider);
      if (esEdicion) {
        await repo.updateDescuento(descuento);
      } else {
        await repo.createDescuento(descuento);
      }
      GlobalMessenger.showSuccessSnackbar(esEdicion ? 'Descuento actualizado' : 'Descuento creado');
    } catch (e) {
      if (mounted) setState(() => _descuentos = previousDescuentos);
      GlobalMessenger.showErrorSnackbar('Ocurrió un error inesperado al guardar el descuento. Verifica tu conexión e intenta de nuevo.');
    }
  }

  Future<void> _eliminarDescuento(Descuento descuento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteConfirmDialog(
        title: 'Eliminar descuento',
        message: '¿Seguro que querés eliminar este descuento? Esta acción no se puede deshacer.',
      ),
    );
    if (confirmar != true) return;

    final repo = ref.read(descuentoRepositoryProvider);
    await repo.deleteDescuento(descuento.id!);
    if (mounted) {
      setState(() => _descuentos.removeWhere((d) => d.id == descuento.id));
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
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => const LogoutConfirmDialog(),
              );
              if (confirm == true) {
                await ref.read(authServiceProvider).signOut();
                if (mounted) context.go('/login');
              }
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

        // Panel de descuentos — ancho responsivo (18% de pantalla, mín 180 / máx 240)
        SizedBox(
          width: (MediaQuery.of(context).size.width * 0.18).clamp(180.0, 240.0),
          child: DescuentosPanel(
            descuentos: _descuentos,
            onAgregarDescuento: () => _mostrarFormDescuento(context),
            onEliminarDescuento: (descuento) => _eliminarDescuento(descuento),
            onEditarDescuento: (descuento) =>
                _mostrarFormDescuento(context, descuento: descuento),
          ),
        ),
      ],
    );
  }
}
