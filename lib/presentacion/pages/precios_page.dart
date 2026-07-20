import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/descuento_model.dart';
import 'package:le_groupe_gym/data/models/precio_model.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // TopBar
          _buildTopBar(),
          Sidebar(
            currentRoute: '/precios',
            isCollapsed: _sidebarCollapsed,
            onCerrarSesion: () async {
              await SupabaseConfig.client.auth.signOut();
              if (mounted) context.go('/login');
            },
            onNavigate: (route) => context.go(route),
          ),

          // Contenido
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.onSurface, size: 22),
            onPressed: () =>
                setState(() => _sidebarCollapsed = !_sidebarCollapsed),
          ),
          Text(
            'Planes y Tarifas',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: Text(
              'Nuevo Plan',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
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
                Text(
                  'Planes de Suscripción',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: _precios
                      .map(
                        (precio) => _PrecioCard(
                          precio: precio,
                          onEditar: () {},
                          onEliminar: () {},
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
          child: _DescuentosPanel(
            descuentos: _descuentos,
            onAgregarDescuento: () {},
            onEliminarDescuento: (_) {},
          ),
        ),
      ],
    );
  }
}

class _PrecioCard extends StatelessWidget {
  final Precio precio;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _PrecioCard({
    required this.precio,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${precio.cantidadDias} días',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              IconButton(
                onPressed: onEditar,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '\$ ${_formatValor(precio.valor)}',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          Text(
            '/ mes',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValor(int valor) {
    return valor.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

class _DescuentosPanel extends StatelessWidget {
  final List<Descuento> descuentos;
  final VoidCallback onAgregarDescuento;
  final Function(Descuento) onEliminarDescuento;

  const _DescuentosPanel({
    required this.descuentos,
    required this.onAgregarDescuento,
    required this.onEliminarDescuento,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Gestión de Descuentos',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: onAgregarDescuento,
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Descuentos Aplicables',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...descuentos.map(
            (descuento) => _DescuentoItem(
              descuento: descuento,
              onEliminar: () => onEliminarDescuento(descuento),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescuentoItem extends StatelessWidget {
  final Descuento descuento;
  final VoidCallback onEliminar;

  const _DescuentoItem({required this.descuento, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: const BorderRadius.all(AppRadius.sm),
              ),
              child: Text(
                '-${descuento.valor}%',
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onEliminar,
            icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
