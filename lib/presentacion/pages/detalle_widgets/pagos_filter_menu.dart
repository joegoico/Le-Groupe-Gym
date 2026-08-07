import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

class PagosFilterMenu extends StatelessWidget {
  final Function(String) onFilterSelected;

  const PagosFilterMenu({super.key, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.filter_list,
            color: AppColors.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            'Filtrar',
            style: GoogleFonts.inter(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
      color: AppColors.surfaceContainerHigh,
      onSelected: onFilterSelected,
      itemBuilder: (context) {
        final meses = [
          'Enero',
          'Febrero',
          'Marzo',
          'Abril',
          'Mayo',
          'Junio',
          'Julio',
          'Agosto',
          'Septiembre',
          'Octubre',
          'Noviembre',
          'Diciembre',
        ];

        return [
          PopupMenuItem(
            value: 'todos',
            child: Text(
              'Todos los de este año',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
          const PopupMenuDivider(),
          ...List.generate(12, (index) {
            return PopupMenuItem(
              value: 'mes_${index + 1}',
              child: Text(
                meses[index],
                style: GoogleFonts.inter(color: Colors.white),
              ),
            );
          }),
        ];
      },
    );
  }
}
