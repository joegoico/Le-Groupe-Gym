import 'package:flutter/material.dart';

import 'page_button.dart';

class PaginationTable extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;

  const PaginationTable({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final pages = List.generate(
      totalPages,
      (i) => i,
    ).where((p) => (p - currentPage).abs() <= 1).toList();

    return Row(
      children: [
        PageButton(
          icon: Icons.chevron_left,
          onTap: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
        ),
        ...pages.map(
          (p) => PageButton(
            label: '${p + 1}',
            isActive: p == currentPage,
            onTap: () => onPageChanged(p),
          ),
        ),
        PageButton(
          icon: Icons.chevron_right,
          onTap: currentPage < totalPages - 1
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }
}
