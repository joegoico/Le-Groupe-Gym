import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/ingreso_model.dart';
import 'package:le_groupe_gym/presentacion/pages/ingresos_widgets/table_widgets/ingreso_row.dart';
import 'package:le_groupe_gym/presentacion/pages/ingresos_widgets/table_widgets/paginattion_table.dart';

const _kPageSize = 10;

/// Tabla de transacciones con buscador y paginación client-side.
class IngresoTable extends StatefulWidget {
  final List<Ingreso> ingresos;

  const IngresoTable({super.key, required this.ingresos});

  @override
  State<IngresoTable> createState() => _IngresoTableState();
}

class _IngresoTableState extends State<IngresoTable> {
  String _query = '';
  int _page = 0;

  List<Ingreso> get _filtered => widget.ingresos
      .where((i) => i.concepto.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  List<Ingreso> get _pageItems {
    final f = _filtered;
    final start = _page * _kPageSize;
    if (start >= f.length) return [];
    return f.sublist(start, (start + _kPageSize).clamp(0, f.length));
  }

  int get _totalPages => (_filtered.length / _kPageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('dd MMM yyyy', 'es');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // — Header con buscador —
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Text(
                  'Listado de Transacciones',
                  style: AppTextStyles.titleMd.copyWith(fontSize: 16),
                ),
                const Spacer(),
                SizedBox(
                  width: 240,
                  child: TextField(
                    onChanged: (v) => setState(() {
                      _query = v;
                      _page = 0;
                    }),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar por concepto...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainerHigh,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // — Cabecera de columnas —
          const Divider(height: 1, color: AppColors.outlineVariant),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _ColHeader('Fecha', flex: 2),
                _ColHeader('Concepto', flex: 4),
                _ColHeader('Medio de Pago', flex: 2),
                _ColHeader('Monto', flex: 2, align: TextAlign.right),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),

          // — Filas —
          if (_pageItems.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'No se encontraron transacciones.',
                  style: AppTextStyles.subtittles,
                ),
              ),
            )
          else
            ...(_pageItems.map(
              (i) => IngresoRow(ingreso: i, dateFmt: dateFmt, montoFmt: fmt),
            )),

          // — Footer paginación —
          const Divider(height: 1, color: AppColors.outlineVariant),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  'Mostrando ${_pageItems.length} de ${_filtered.length} registros',
                  style: AppTextStyles.labelCaps,
                ),
                const Spacer(),
                PaginationTable(
                  currentPage: _page,
                  totalPages: _totalPages,
                  onPageChanged: (p) => setState(() => _page = p),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign align;

  const _ColHeader(this.text, {this.flex = 1, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text, textAlign: align, style: AppTextStyles.labelCaps),
    );
  }
}
